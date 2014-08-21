import sys, re

class cls:
    WarnMacros=False
    Arguments=None

commentre = re.compile(r"^#(?:[ \t]*#)+([^#])", re.MULTILINE)
pmccommentre = re.compile(r"^[ \t]*;;([ \t]*[^;#]*)", re.MULTILINE)
recordre = re.compile(r"^([ \t]*record[^{]*?)$",re.MULTILINE)
removecb = re.compile(r"^[ \t]*{(.*?)$", re.MULTILINE)
# alias outside of a recford() will have (a,b) argument
aliasre = re.compile(r"^([ \t]*alias[^,]*?,[^,]*?)$",re.MULTILINE)

def Input_filter(fname):
    """Doxygen input filter. Take the file fname, and if it is a protocol or 
    database file, then do some preprocessing on it to make it look like a C
    file for doxygen. This allows the use of # comments, and the extraction of 
    the DESC field of database files."""
    if fname.endswith(".protocol") or fname.endswith(".proto"):
        text = open(fname).read()
        text = text.replace("{","(){")
        text = re.sub(commentre,r"///\1",text)
        print text
    elif fname.endswith(".vdb") or fname.endswith(".template") or fname.endswith(".db"):
        text = open(fname).read()
        text = re.sub(removecb,r"\1",text)
        text = re.sub(recordre,r"\1 {",text)
        text = re.sub(aliasre,r"\1 { }",text)
        # no comments, try making some
        text = re.sub(".*field.*\(.*DESC,.*\"(.*)\".*\)",r"///\c DESC field: \1",text)
        # Make sure double hashed comments are picked up
        text = re.sub(commentre,r"///\1",text)        
        # make a macro list
        from iocbuilder.autosubst import populate_class        
        populate_class(cls, fname)
        print text
        print
        print r"/** \file"
        def get_desc(macro):
            return cls.ArgInfo.descriptions[macro].desc.replace("<type 'str'>", "")

        for macro in cls.ArgInfo.required_names:
            print r"\param %s Required argument. %s" % (macro, get_desc(macro))
        for macro, default in zip(cls.ArgInfo.default_names, cls.ArgInfo.default_values):
            print r"\param %s Default=%s. %s" % (macro, default, get_desc(macro))
        for macro in cls.ArgInfo.optional_names:
            print r"\param %s Optional argument. %s" % (macro, get_desc(macro))
        print r"\n**/"        
    elif fname.endswith(".pmc"):
        text = open(fname).read()
        text = re.sub(pmccommentre,r"///\1",text)                
        text = re.sub(";",r"//",text)                        
        print text        
    else:
        print open(fname).read()           
    
if __name__=="__main__":
    Input_filter(sys.argv[1])
