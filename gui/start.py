#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
from gui.tisaneGui import TisaneGUI # gui.tisaneGui
# from helpers.statisticalModel import StatisticalModel
# from helpers.code_generator import *
# from tisaneGui import TisaneGUI
from gui.tisanecodegenerator import CodeGenerator, StatisticalModel


import dash
import dash_bootstrap_components as dbc
from dash import html
import socket  # For finding next available socket
from typing import List, Set, Dict, Union
from pathlib import Path
import json 
import logging

log = logging.getLogger("")
log.setLevel(logging.ERROR)

tg = TisaneGUI()

# main_only_input = os.path.join(
#         # os.path.dirname(__file__), 
#         "gui/example_inputs/main_only.json"
#     )


### Helper function 
# @param file is the path to the JSON file from which to construct the statistical model
def construct_statistical_model(filename: Path):
    log.info(f"read through {filename}")
    assert filename.endswith(".json")
    dir = os.getcwd()
    path = Path(dir, filename)

    # Read in JSON file as a dict
    file_data = None
    with open(path, "r") as f:
        file_data = f.read()
    model_dict = json.loads(file_data)  # file_data is a string

    # Specify dependent variable
    dependent_variable = model_dict["dependent variable"]

    # Specify main effects 
    main_effects = set(model_dict["main effects"])

    # Specify interaction effects
    interaction_effects = set(model_dict["interaction effects"])

    # Specify random effects
    re_dict = model_dict["random effects"]
    assert(isinstance(re_dict, dict))

    random_effects = set(list())
    
    # Specify family function
    family_function = model_dict["family"]

    # Specify link function 
    link_function = model_dict["link"]

    # Construct Statistical Model
    sm = StatisticalModel(
        dependent_variable,
        main_effects,
        interaction_effects,
        random_effects,
        family_function,
        link_function,
    )

    return sm


### Step 4: GUI generates code
def generateCode(
        destinationDir: str = None, modelSpecJson: str = "model_spec.json"
    ):
        destinationDir = destinationDir or os.getcwd()
        output_filename = os.path.join(
            destinationDir, modelSpecJson
        )  # or whatever path/file that the GUI outputs

        ### Step 4: Code generation
        # Construct StatisticalModel from JSON spec
        sm = construct_statistical_model(
            filename=output_filename, # JSON specifying the statistical model 
        )
        # TODO: Incorporate data 
        # Options: 
        # (1) Add data (filepath or dataframe direclty into JSON fed into statistical model disambiguation)
        # (2) ...?
        
        # if design.has_data():
        #     # Assign statistical model data from @param design
        #     sm.assign_data(design.dataset)
        
        # Generate code from SM
        cg = CodeGenerator(sm)
        # Write generated code out
        output_file_path = os.path.join(destinationDir)
        path = cg.write_out_file(output_file_path)
        
        # Return 
        return path


inputFile = "input2.json" # Output after disambiguating conceptual model, could rename to "statistical_model_choices.json"
# inputFile = "examples/json/mainEffectsOnly.json"
tg.start_app(input=inputFile, generateCode=generateCode)
