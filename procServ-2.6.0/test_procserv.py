import telnetlib3
import time
tn1=telnetlib3.Telnet('localhost',20000)
while True :
    for i in range(10) :
        tn1.read_very_eager()
        tn1.write('dbl\n')
        time.sleep(2)
        tn1.write('\n\n\n\n\n\n')
        time.sleep(1)
    # connect to main port (r/w)
    tn=telnetlib3.Telnet('localhost',20000)
    for i in range(5) :
        tn.read_very_eager()
        tn.write('dbl\n')
        time.sleep(2)
        tn.write('\n\n\n\n\n\n')
        time.sleep(1)
    # connect to log port (ro)
    tn2=telnetlib3.Telnet('localhost',20001)
    time.sleep(3)
    tn2.read_very_eager()
    time.sleep(1)
    tn2.close()
    tn.close()
tn1.close()
