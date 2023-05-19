# Introduction 
✋ **Status check:** At this point, you have successfully installed rTisane! If not, look at [the instructions for installing rTisane](tutorial/start.qmd) or [ask for help](https://github.com/emjun/rTisane/issues). 

**What you will learn:** will use rTisane to author a statistical model without a priori knowing how exactly to formulate it. 

In five steps (!!!), rTisane will help you leverage what you know about your domain in order to mathematically formulate a statistical model and implement it in code.

Note: Although a dataset is not required to use rTisane, if included, a dataset must be in long format. Furthermore, if a dataset is used, some [parameters for declaring variables become optional](#measures). rTisane will infer them from the dataset. 


# Consider the following scenario: 
> You want to know the influence of tutoring on student test performance. To this end, you conduct a study involving 100 students. For each student, you collect data about their race, socioeconomic background, number of extra-curriculars, and test score. Additionally, you randomly assign each student to one of two tutoring conditions: online tutoring vs. in-person tutoring.