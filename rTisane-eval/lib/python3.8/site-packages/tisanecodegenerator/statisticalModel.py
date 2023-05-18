from typing import Set, Union
import os
import pandas as pd


class StatisticalModel:
    dependent_variable: str
    main_effects: Set[str]
    interaction_effects: Set[str]
    random_effects: Set[str]
    family_function: str
    link_function: str
    # dataset: Dataset

    def __init__(
        self,
        dependent_variable: str,
        main_effects: Set[str],
        interaction_effects: Set[str],
        random_effects: Set[str],
        family_function: str,
        link_function: str,
    ):
        self.dependent_variable = dependent_variable
        self.main_effects = main_effects
        self.interaction_effects = interaction_effects
        self.random_effects = random_effects
        self.family_function = family_function
        self.link_function = link_function
        # self.dataset = None  # Default is that there is no data until assigned

    def get_independent_variables(self):
        ivs = set()
        ivs = ivs.union(self.main_effects)
        ivs = ivs.union(self.interaction_effects)
        ivs = ivs.union(self.random_effects)

        return ivs

    def get_dependent_variable(self):
        return self.dependent_variable

    # @returns this statistical model's data
    def get_data(self):

        return self.dataset

    # Add data to this statistical model
    def assign_data(self, source: Union[os.PathLike, pd.DataFrame]):
        self.dataset = source
        # if isinstance(source, os.PathLike):
        #     # TODO: Read in file
        #     self.dataset = source
        # else:
        #     self.dataset = source

        return self

    # @returns bool val if self.dataset is not None
    def has_data(self):
        return self.dataset is not None

    def has_random_effects(self):
        return len(self.random_effects) > 0
