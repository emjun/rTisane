from tisanecodegenerator.statisticalModel import StatisticalModel
from tisanecodegenerator.codeGeneratorStrings import CodeGeneratorStrings

import os
from pathlib import Path
from typing import List, Any, Tuple
# import pandas as pd
import logging

log = logging.getLogger(__name__)
log.setLevel(logging.ERROR)

class CodeGenerator: 
    def __init__(self, statisticalModel: StatisticalModel, dataPath: os.PathLike=None): 
        self.strings = CodeGeneratorStrings()
        self.statisticalModel = statisticalModel
        if isinstance(dataPath, os.PathLike): 
            if (dataPath.suffix != ".csv"): 
                raise ValueError("Data path provided is not a CSV. Please provide a CSV.")
        self.dataPath= dataPath
    
    def construct_code_snippet(self, lines:dict): 
        snippet = str()
        for key, value in lines.items(): 
            snippet += value + "\n"

        return snippet 

    def write_out_file(self, path: os.PathLike=None) -> os.path: 
        filename = "model.R"
        
        if path: # If @param path is specified
            output_file_path = os.path.join(path, filename)
        else: # If @param path is not specified
            output_file_path = os.path.join(os.path.dirname(__file__), filename)
        
        # Get handle to file (file object)
        output_file = open(output_file_path, "w") 
        script = self.script()

        output_file.writelines(script)

        # Return path to modeling file
        return os.path.join(output_file_path)

    def script(self): 
        # Generate code snippets for each part of the script
        preamble = self.preamble()
        loading = self.loading()
        modeling = self.modeling() 
        summary = self.summary()

        # Combine the code snippets 
        code = preamble + loading + modeling + summary

        # Return the complete script
        return code
        
    def preamble(self): 
        installs = self.strings.get("installs")
        imports = self.strings.get("imports")

        installs_snippet = self.construct_code_snippet(installs)
        imports_snippet = self.construct_code_snippet(imports)

        # Combine
        preamble_snippet = installs_snippet + "\n" + imports_snippet
        
        # Return 
        return preamble_snippet

    def loading(self): 
        data = self.strings.get("data")

        data_snippet = self.construct_code_snippet(data)
        
        if self.dataPath is not None: 
            data_snippet = data_snippet.format(path=self.dataPath)
        else: 
            # Add comment
            comment_to_add_path = "# Replace 'PATH' with a path to your data"
            data_snippet = comment_to_add_path + "\n" + data_snippet.format(path='PATH')
            
        # Return 
        return data_snippet

    def modeling(self): 
        # Is this a generalized linear model without random effects?
        if not self.statisticalModel.has_random_effects(): 
            model = self.strings.get("glm")
        else: 
            model = self.strings.get("glmer")
        modeling_snippet = self.construct_code_snippet(model)   
        
        # Create formula pieces
        dv = self.statisticalModel.dependent_variable
        ivs = self.statisticalModel.get_independent_variables()
        ivs = "+".join(ivs)
        family = self.statisticalModel.family_function.lower()
        link = self.statisticalModel.link_function.lower()
        # Construct modeling code including formula, family, link, and data
        modeling_snippet = modeling_snippet.format( dv=dv, 
                                                    ivs=ivs, 
                                                    family=family, 
                                                    link=link, 
                                                    data="data"
                                                    )

        # Return 
        return modeling_snippet    

    def summary(self): 
        # Visualize
        return ""
    