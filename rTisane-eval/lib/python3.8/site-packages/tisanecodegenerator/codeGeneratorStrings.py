import json
import os
import logging

log = logging.getLogger(__name__)
log.setLevel(logging.ERROR)

class CodeGeneratorStrings:  
    def __init__(self): 
        self.data = {}
        dir = os.path.dirname(os.path.abspath(__file__))
        stringsPath = os.path.join(dir, "strings.json")
        if os.path.exists(stringsPath):
            with open(stringsPath, "r") as f:
                self.data = json.loads(f.read())
                pass
            pass
        else:
            log.error("Could not find strings.json file in dir {}".format(dir))
            exit(1)
            pass
        pass

    def get(self, nameOfSnippet:str): 
        return self.data.get(nameOfSnippet)
