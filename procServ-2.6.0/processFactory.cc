// Process server for soft ioc
// David H. Thompson 8/29/2003
// Ralph Lange 04/13/2012
// GNU Public License (GPLv3) applies - see www.gnu.org

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>
#include <arpa/inet.h>
#include <signal.h>
#include <time.h>
#include <string.h>
#include <strings.h>

#ifdef __CYGWIN__
#include <sys/cygwin.h>
#endif /* __CYGWIN__ */

// forkpty()
#ifdef HAVE_LIBUTIL_H      // FreeBSD
#include <libutil.h>
#endif
#ifdef HAVE_UTIL_H         // Mac OS X
#include <util.h>
#endif
#ifdef HAVE_PTY_H          // Linux
#include <pty.h>
#endif
#ifndef HAVE_FORKPTY       // Solaris, use our own implementation
extern "C" int forkpty(int*, char*, void*, void*);
#endif

#include "procServ.h"
#include "processClass.h"

#define LINEBUF_LENGTH 1024

processClass * processClass::_runningItem=NULL;
time_t processClass::_restartTime=0;

bool processFactoryNeedsRestart()
{
    time_t now = time(0);
    if ( ( autoRestart == false && processClass::_restartTime ) || 
         processClass::_runningItem ||
         now < processClass::_restartTime ||
         waitForManualStart ) return false;
    return true;
}

connectionItem * processFactory(char *exe, char *argv[])
{
    char buf[512];
    time(&IOCStart); // Remember when we did this

    if (processFactoryNeedsRestart())
    {
	sprintf( buf, "@@@ Restarting child \"%s\"" NL, childName );
	SendToAll( buf, strlen(buf), 0 );

        if ( strcmp( childName, argv[0] ) != 0 ) {
            sprintf( buf, "@@@    (as %s)" NL, argv[0] );
            SendToAll( buf, strlen(buf), 0 );
        }

        connectionItem *ci = new processClass(exe, argv);
        PRINTF("Created new child connection (processClass %p)\n", ci);
	return ci;
    }
    else
	return NULL;
}

processClass::~processClass()
{

    struct tm now_tm;
    time_t now;
    size_t result;
    char now_buf[128] = "@@@ Current time: ";
    char goodbye[128];

    time( &now );
    localtime_r( &now, &now_tm );
    result = strftime( &now_buf[strlen(now_buf)], sizeof(now_buf) - strlen(now_buf) - 1,
                       timeFormat, &now_tm );
    if (result && (sizeof(now_buf) - strlen(now_buf) > 2)) {
        strcat(now_buf, NL);
    } else {
        strcpy(now_buf, "@@@ Current time: N/A");
    }
    sprintf ( goodbye, "@@@ Child process is shutting down, %s" NL,
              autoRestart ? "a new one will be restarted shortly" :
              "auto restart is disabled" );

    // Update client connect message
    sprintf( infoMessage2, "@@@ Child \"%s\" is SHUT DOWN" NL, childName );

    SendToAll( now_buf, strlen(now_buf), this );
    SendToAll( goodbye, strlen(goodbye), this );
    SendToAll( infoMessage3, strlen(infoMessage3), this );

                                // Negative PID sends signal to all members of process group
//#ifndef __CYGWIN__ /* FAA: check later */
    if ( _pid > 0 ) kill( -_pid, SIGKILL );
//#endif
	terminateJob();
	if ( _fd > 0 ) close( _fd );
    _runningItem = NULL;
}


// Process class constructor
// This forks and
//    parent: sets the minimum time for the next restart
//    child:  sets the coresize, becomes a process group leader,
//            and does an execvp() with the command
processClass::processClass(char *exe, char *argv[])
{
    _runningItem=this;
    struct rlimit corelimit;
    char buf[128];

#ifdef __CYGWIN__
	// we can only be a member of one job object in windows 7 and below, so we put the child in the job
	// object to control termination of any process it spawns. If the parent exits, as we have set the job object
	// to kill on close it should also exit the child so we don't need to use nested job objects
	_hwinjob = CreateJobObject(NULL, NULL);
	if (_hwinjob == NULL)
	{
            fprintf(stderr, "CreateJobObject failed\n");
	}
	// set processes assigned to a job to automatically terminate when the job handle object is closed.
	// This is for additional secuiry - we call TerminateJobObject() as well 
	JOBOBJECT_EXTENDED_LIMIT_INFORMATION job_limits;
	if (QueryInformationJobObject(_hwinjob, JobObjectExtendedLimitInformation, &job_limits, sizeof(JOBOBJECT_EXTENDED_LIMIT_INFORMATION), NULL) != 0)
	{
		job_limits.BasicLimitInformation.LimitFlags |= JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
		if (SetInformationJobObject(_hwinjob, JobObjectExtendedLimitInformation, &job_limits, sizeof(JOBOBJECT_EXTENDED_LIMIT_INFORMATION)) == 0)
		{
            fprintf(stderr, "SetInformationJobObject failed\n");
		}
	}
	else
	{
            fprintf(stderr, "QueryInformationJobObject failed\n");
	}
#endif /* __CYGWIN__ */
	
	
    _pid = forkpty(&_fd, factoryName, NULL, NULL);

    _markedForDeletion = _pid <= 0;
    if (_pid)                               // I am the parent
    {
	    if(_pid < 0) {
            fprintf(stderr, "Fork failed: %s\n", errno == ENOENT ? "No pty" : strerror(errno));
        } else {
            PRINTF("Created process %ld on %s\n", (long) _pid, factoryName);
        }
#ifdef __CYGWIN__
	    int winpid = cygwin_internal(CW_CYGWIN_PID_TO_WINPID, _pid);
        PRINTF("Created win process %ld on %s\n", (long) winpid, factoryName);

		HANDLE hprocess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, winpid); 
		if (hprocess != NULL)
		{
			if (AssignProcessToJobObject(_hwinjob, hprocess) != 0)
			{
				PRINTF("Assigned win process %ld to job object\n", (long)winpid);
			}
			else
			{
				fprintf(stderr, "AssignProcessToJobObject failed\n");
			}
			if (CloseHandle(hprocess) == 0)
			{
				fprintf(stderr, "CloseHandle(hprocess) failed\n");
			}
		}
		else
		{
			fprintf(stderr, "OpenProcess failed for win process %ld\n", (long)winpid);
		}
#endif /* __CYGWIN__ */

        // Don't start a new one before this time:
        _restartTime = holdoffTime + time(0);

        // Update client connect message
        sprintf(infoMessage2, "@@@ Child \"%s\" PID: %ld" NL, childName, (long) _pid);

        sprintf(buf, "@@@ The PID of new child \"%s\" is: %ld" NL, childName, (long) _pid);
        SendToAll( buf, strlen(buf), this );
        strcpy(buf, "@@@ @@@ @@@ @@@ @@@" NL);
        SendToAll( buf, strlen(buf), this );

		
    }
    else                                    // I am the child
    {
	    sleep(1);   // to allow AssignProcessToJobObject() to happen - the process we spawn may spawn other processes so we want it to inherit
        setsid();                                  // Become process group leader
        if ( setCoreSize ) {                       // Set core size limit?
            getrlimit( RLIMIT_CORE, &corelimit );
            corelimit.rlim_cur = coreSize;
            setrlimit( RLIMIT_CORE, &corelimit );
        }
        if ( chDir && chdir( chDir ) ) {
            fprintf( stderr, "%s: child could not chdir to %s, %s\n",
                     procservName, chDir, strerror(errno) );
        } else {
            execvp(exe, argv);              // execvp()
        }

	// This shouldn't return, but did...
	fprintf( stderr, "%s: child could not execute: %s, %s\n",
                 procservName, *argv, strerror(errno) );
	exit( -1 );
    }
}

// processClass::readFromFd
// Reads, checks for EOF/Error, and sends to the other connections
void processClass::readFromFd(void)
{
    char  buf[1600];

    int len = read(_fd, buf, sizeof(buf)-1);
    if (len < 0) {
        PRINTF("processItem: Got error reading input connection: %s\n", strerror(errno));
        _markedForDeletion = true;
    } else if (len == 0) {
        PRINTF("processItem: Got EOF reading input connection\n");
        _markedForDeletion = true;
    } else {
        buf[len]='\0';
        SendToAll(&buf[0], len, this);
    }
}

// Sanitize buffer, then send characters to child
int processClass::Send( const char * buf, int count )
{
    int status = 0;
    int i, j, nsend, ign = 0;
    char buf3[LINEBUF_LENGTH+1];
    char *buf2 = buf3;
	fd_set writefds;
	struct timeval select_timeout;
	FD_ZERO(&writefds);
	FD_SET(_fd, &writefds);
	int wait_time = 10;
	select_timeout.tv_sec = wait_time;
	select_timeout.tv_usec = 0;

                                // Create working copy of buffer
    if ( count > LINEBUF_LENGTH ) buf2 = (char*) calloc (count + 1, 1);
    buf2[0] = '\0';

    if ( ignChars ) {           // Throw out ignored chars
        for ( i = j = 0; i < count; i++ ) {
            if ( index( ignChars, (int) buf[i] ) == NULL ) {
                buf2[j++] = buf[i];
            } else ign++;
        }
    } else {                    // Plain buffer copy
        strncpy (buf2, buf, count);
    }
	nsend = count - ign;
    buf2[nsend] = '\0';

	// we seem to get occasional hangs in cygwin fhandler_pty_master::doecho()
	// not sure is using select() will help, but will try
    if ( nsend > 0 )
    {
		if ( (status = select(_fd+1, NULL, &writefds, NULL, &select_timeout)) > 0 )
		{
			status = write( _fd, buf2, nsend );
			if ( status < 0 ) // write() failed
			{
                PRINTF("processItem: Got error writing to input connection: %s\n", strerror(errno));
				_markedForDeletion = true;
			}
			else if ( status != nsend ) // write() did not fully complete
			{
				PRINTF("processItem: only wrote %d of %d characters\n", status, nsend);
				_markedForDeletion = true;
			}
		}
		else if ( 0 == status ) // select() timeout
		{
			PRINTF("processItem: select timeout after %d seconds\n", wait_time);
			status = -1;
			_markedForDeletion = true;
		}
		else // status < 0, select() error
		{
			PRINTF("processItem: select error: %s\n", strerror(errno));
			_markedForDeletion = true;
		}
	}
    if ( count > LINEBUF_LENGTH ) free( buf2 );
    return status;
}

// The telnet state machine can call this to blast a running
// client IOC
void processFactorySendSignal(int signal)
{
    if (processClass::_runningItem)
    {
//#ifndef __CYGWIN__ /* FAA: check later */
	PRINTF("Sending signal %d to pid %ld\n",
		signal, (long) processClass::_runningItem->_pid);
	kill(-processClass::_runningItem->_pid,signal);
//#endif
	if (signal == killSig)
	{
	    processClass::_runningItem->terminateJob();
	}
	
    }
}

void processClass::restartOnce ()
{
    _restartTime = 0;
}

void processClass::terminateJob()
{
#ifdef __CYGWIN__
	if (_hwinjob != NULL)
	{
		int winpid = cygwin_internal(CW_CYGWIN_PID_TO_WINPID, processClass::_runningItem->_pid);
	    PRINTF("Terminating cygwin pid %ld (win pid %ld)\n", (long)processClass::_runningItem->_pid, (long)winpid);
//		winkill(winpid); // terminating job object should be enough
	    if (TerminateJobObject(_hwinjob, 1) == 0)
		{
			fprintf(stderr, "TerminateJobObject failed\n");
		}
	    if (CloseHandle(_hwinjob) == 0)
		{
			fprintf(stderr, "CloseHandle(_hwinjob) failed\n");
		}
		_hwinjob = NULL;
	}
#endif /* __CYGWIN__ */
}

void processClass::winkill(int winpid)
{
#ifdef __CYGWIN__
	HANDLE hprocess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, winpid);
	if (hprocess != NULL)
	{
	    if (TerminateProcess(hprocess, 1) == 0)
		{
			fprintf(stderr, "TerminateProcess failed\n");			
		}
		if (CloseHandle(hprocess) == 0)
		{
			fprintf(stderr, "CloseHandle(hprocess) failed\n");			
		}
	}
	else
	{
		fprintf(stderr, "OpenProcess failed\n");		
	}
#endif /* __CYGWIN__ */
}

