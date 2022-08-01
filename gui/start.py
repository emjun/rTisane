#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
from gui.tisaneGui import TisaneGUI
# from tisaneGui import TisaneGUI
import dash
import dash_bootstrap_components as dbc
from dash import html
import socket  # For finding next available socket

tg = TisaneGUI()

# main_only_input = os.path.join(
#         # os.path.dirname(__file__), 
#         "gui/example_inputs/main_only.json"
#     )

### Step 4: GUI generates code
def generateCode(
        destinationDir: str = None, modelSpecJson: str = "model_spec.json"
    ):
        destinationDir = destinationDir or os.getcwd()
        output_filename = os.path.join(
            destinationDir, modelSpecJson
        )  # or whatever path/file that the GUI outputs

        print(destinationDir)

        ### Step 4: Code generation
        # Construct StatisticalModel from JSON spec
        # model_json = f.read()
        # sm = construct_statistical_model(
        #     filename=output_filename,
        #     query=design,
        #     main_effects_candidates=main_effects_candidates,
        #     interaction_effects_candidates=interaction_effects_candidates,
        #     random_effects_candidates=random_effects_candidates,
        #     family_link_paired_candidates=family_link_paired,
        # )

        # if design.has_data():
        #     # Assign statistical model data from @parm design
        #     sm.assign_data(design.dataset)
        # # Generate code from SM
        # code = generate_code(sm)
        # # Write generated code out

        # path = write_to_script(code, destinationDir, "model.py")
        # return path

# inputFile = "gui/example_inputs/main_only.json"
inputFile = "examples/json/mainEffectsOnly.json"
tg.start_app(input=inputFile, generateCode=generateCode)