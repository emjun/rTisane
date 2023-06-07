from flask import request
import logging
import json
import plotly.figure_factory as ff
import plotly.express as px
import dash
import dash_daq as daq
import dash_bootstrap_components as dbc
from dash import dcc
from dash import html
from dash.dependencies import Output, Input, State, ALL, MATCH
from dash.exceptions import PreventUpdate
# from jupyter_dash import JupyterDash
import plotly.graph_objects as go
import webbrowser  # For autoamtically opening the browser for the CLI
import socket  # For finding next available socket
from gui.gui_components import GUIComponents  # gui.gui_components
from gui.callbacks import createCallbacks # gui.callbacks

external_stylesheets = [
    dbc.themes.BOOTSTRAP,
    {
        "rel": "stylesheet",
        "href": "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css",
    },
]

# Find socket info
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(("", 0))
addr = s.getsockname()
port = addr[1]
s.close()
logging.basicConfig(level=logging.ERROR)

# For logging Dash output
log = logging.getLogger("werkzeug")
log.setLevel(logging.ERROR)

# port = '0' # FYI: default dash port is 8050
def open_browser():
    global port
    webbrowser.open_new("http://localhost:{}".format(port))


# open_browser()
# Write data to a file
def write_data(data: dict):
    with open("model_spec.json", "w") as f:
        f.write(json.dumps(data))


class TisaneGUI:
    app: dash.Dash

    def __init__(self):
        pass

    # @param input is a json file that has all the data to read in
    def read_input(self, input: str, generateCode):
        self.components = GUIComponents(input, generateCode)
        pass

    # @param input is a json file that has all the data to read in
    def start_app(self, input: str, jupyter: bool = False, generateCode=None):
        ### Read in input data
        self.read_input(input, generateCode)

        ### Create app
        app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
        # if jupyter:
        #     app = JupyterDash(__name__, external_stylesheets=external_stylesheets)
        #     pass
        # else:
        #     app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

        ### Populate app
        # Get components
        # progress = self.progress()
        # TODO: Add callback that enables this button once all the tabs/sections have been completed
        # generate_code_button = dbc.Button(
        #     "✨Generate code✨", color="dark", className="mr-1", disabled=True
        # )
        overview = self.overview()
        model_tabs = self.model_tabs()

        # Layout components that require special formatting
        # Build progress row

        # Number of tabs to show
        # Remove random effects tab for controlled lab study focusing on GLMs
        num_tabs = 3
        val = 100/num_tabs

        progress_row = [
            dbc.Col(
                dbc.Progress(
                    [
                        dbc.Progress(
                            self.components.strings.access("progress", "main-effects"),
                            value=val,
                            animated=True,
                            striped=True,
                            bar=True,
                            id="main-effects-progress",
                        ),
                        dbc.Progress(
                            self.components.strings("progress", "interaction-effects"),
                            value=val,
                            animated=False,
                            bar=True,
                            id="interaction-effects-progress",
                            color="secondary",
                        ),
                        # Remove for controlled lab study focusing only on GLMs
                        # dbc.Progress(
                        #     self.components.strings("progress", "random-effects"),
                        #     value=25,
                        #     animated=False,
                        #     bar=True,
                        #     id="random-effects-progress",
                        #     color="secondary",
                        # ),
                        dbc.Progress(
                            self.components.strings(
                                "progress", "family-link-functions"
                            ),
                            value=val,
                            animated=False,
                            bar=True,
                            id="family-link-functions-progress",
                            color="secondary",
                        ),
                    ],
                    # multi=True,
                    style={"height": "2rem"},
                ),
                width=12,
            )
        ]

        # Add all components to main app's layout
        app.layout = dbc.Container(
            [
                html.H1("🌺 rTisane"),
                dbc.Row(progress_row),
                html.Br(),
                # Split screen between overview and model specification tabs
                dbc.Row(
                    [
                        dbc.Col(overview, width=4),
                        dbc.Col(model_tabs, width=8),
                    ]
                ),
                dcc.Store(id="added-main-effects-store"),
                dcc.Store(id="added-interaction-effects-store"),
                # dcc.Store(id="random-effects-check-store"),
            ]
            + self.components.createEffectPopovers()
            + self.components.createCodeGenerationModal(),
        )

        ### Start and run app on local server
        self.app = app
        createCallbacks(app, self.components)
        open_browser()
        # if jupyter:
        #     app.run_server(mode="inline", port=port)
        #     pass
        # else:
        #     app.run_server(host="127.0.0.1", debug=False, threaded=True, port=port)

        ## For Debugging
        # app.layout = dbc.Container(
        #     [
        #         html.H1("Tisane")
        #     ]
        # )
        # self.app = app
        app.run_server(host="127.0.0.1", debug=False, threaded=True, port=port) # debugging set to True 


    def model_tabs(self):
        # Many different ways to create tabs: https://dash-bootstrap-components.opensource.faculty.ai/docs/components/tabs/
        tab1_content = self.components.getMainEffectsCard()

        tab2_content = self.components.getInteractionEffectsCard()

        # Remove for controlled lab study focusing on GLMs
        # tab3_content = self.components.getRandomEffectsCard()

        tab4_content = self.components.getFamilyLinkFunctionsCard()

        tabs = dbc.Tabs(
            [
                dbc.Tab(
                    tab1_content,
                    label=self.components.strings.getMainEffectsTabTitle(),
                    tab_style={"marginLeft": "auto"},
                    tab_id="tab-1",
                    id="main-effects-tab",
                ),
                dbc.Tab(
                    tab2_content,
                    label=self.components.strings.getInteractionEffectsTabTitle(),
                    tab_style={"marginLeft": "auto"},
                    tab_id="tab-2",
                    id="interaction-effects-tab",
                ),
                # dbc.Tab(
                #     tab3_content,
                #     label=self.components.strings.getRandomEffectsTabTitle(),
                #     tab_style={"marginLeft": "auto"},
                #     tab_id="tab-3",
                #     id="random-effects-tab",
                # ),
                dbc.Tab(
                    tab4_content,
                    label=self.components.strings.getFamilyLinksTabTitle(),
                    tab_style={"marginLeft": "auto"},
                    tab_id="tab-4",
                    id="family-link-functions-tab",
                ),
            ],
            id="tabs",
        )
        return tabs

    def overview(self):
        query = self.components.getQuery()
        overview = dbc.Card(
            dbc.CardBody(
                [
                    html.H5(
                        self.components.strings.access("overview", "vars-in-query")
                    ),
                    html.P("DV: {}".format(query["DV"])),
                    html.Span(self.components.strings.access("overview", "ivs")),
                    html.Ul(children=[html.Li(iv) for iv in query["IVs"]]),
                    html.H5(self.components.strings.access("overview", "vars-added")),
                    html.Div(
                        [
                            html.H6(
                                self.components.strings.access(
                                    "overview", "main-effects-added"
                                )
                            ),
                            html.Ul(id="added-main-effects"),
                        ]
                        + self.components.getInteractionEffectsAddedSection(),
                        id="added-variables-paragraph",
                    ),
                ]
                # + self.components.getRandomEffectsAddedSection()
                + [
                    html.H5(self.components.strings("overview", "distribution")),
                    html.H6(
                        self.components.strings.access("overview", "family"),
                        id="overview-family",
                    ),
                    html.H6(
                        self.components.strings.access("overview", "link"),
                        id="overview-link",
                    )
                    # html.Div(id="test-div-output")
                ]
            ),
            color="light",
        )

        return overview
