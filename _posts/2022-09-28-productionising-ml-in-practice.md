---
title:  "Productionising Machine Learning pipelines in practice, or how to increase your ML throughput in real life"
--- 

Putting Machine Learning models in production is something I talk a lot about, and I also discuss it with people from 
other companies at conferences, friends and co-workers past and present. While I am strongly convinced that there is a 
lot of value in having multidisciplinary teams of data scientists, machine learning engineers and software engineers 
working closely together, I am also aware that it is not always the optimal organisation.

In this blog post, I will try to summarize what I think would be the ideal organisation for a team dedicated to using 
Machine Learning in a production setting, and we then will see what are some limitations of this approach. 
Finally, I will list some pragmatic workarounds to make the best of what is, and not what should be. 

## An ideal organisation

Let's suppose that you are using Machine Learning to build a product, and not doing Data Science for 
advanced analytics. That entails that the model you produce will be reused several times on new data (though it may be 
the case too if you regenerate a monthly report for example), but more importantly, that the model you have created will
have some kind of integration with the rest of your codebase (either it's called as an independent API, or it becomes 
part of your codebase more directly). 

The first way of organizing the work is to have a team of data scientists building pipelines, and then hand over the 
produced models to a team of software engineers to implement the version for production. This option has obvious advantages: 
you can have specialists focusing on what they do best, the production implementation is independent of the training 
pipeline and can be more efficient because it does not have to care for the training constraints (batch vs online notably).
There are also some major drawbacks: it adds a lot of friction to the delivery process, handover can be lengthy and 
frustrating, the risk of bugs is doubled because the implementation is done twice, etc. It can lead to situations 
where models are sitting for months or even years in the fridge, waiting for someone from the software engineering team
to have the needed bandwidth to deal with it. Even when it is prioritized, it often takes up to 6 months of back and 
forth for the developers to understand what each feature means, match whatever data source was used during modeling to what 
is available in production, implement the predictor in itself, and get both implementations to match. Some of these 
problems can be alleviated if you have a very solid data science platform in place (feature stores, so you don't have to
reimplement feature extraction and cleaning, reproducible training pipelines helping you with the QA process...), but the
friction of having two separate teams of people with different objectives collaborating is harder to mitigate.

An alternative is to give back more agency to your data scientists and set up some infrastructure so that they can deploy
things in production themselves. It might involve packaging everything in a Docker container, or extracting a script 
from a Jupyter Notebook that will then be run periodically in a CRON job, for example. One thing to note with this 
approach is that you are deploying in production code that might not be tested and abiding by quality standards of 
the rest of your codebase. 

My preferred approach is to build multidisciplinary teams, where technical implementation is not a second thought 
after all the data and modelling work has been done. A data scientist with a strong business and modelling expertise 
would start working on a project, and as soon as the proof of concept seems promising, a person with a stronger 
focus on back-end engineering and development, call them a machine learning engineer or something else, would join 
the project and help with refactoring the code, and architecturing the data pipeline in a way that is reproducible, 
maintainable, and ideally scalable. That way, by the time the model is ready to be shipped to production, all the 
code written to support it - from the data extraction glue code, to the actual model implementation, including all 
the data transformation and other feature engineering - is production-ready: versioned, unit-tested and reusable. 
The model and all of its artifacts have also been versioned along the way, making it easy to reproduce any given 
state of the development and to track potential regression.


## Real life limitations

In real life though, it is not always possible to build such teams, for various reasons. 

- need some versatile and motivated data scientists
- set-up costs


## Tools and practices that may help along the way 

### DVC + papermill for fast, but reproducible, iterations

### If you cannot test, monitor, monitor, monitor

### Leverage CI and/or CRON jobs to avoid regressions

### Review code and models
- CML
- nbdime

### Code snippets / utilities / internal library