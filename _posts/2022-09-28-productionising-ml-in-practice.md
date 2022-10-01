---
title:  "Productionising Machine Learning pipelines in practice, or how to increase your ML throughput in real life"
--- 

Putting Machine Learning models in production is something I talk a lot about, and I also discuss it with people from 
other companies at conferences, friends and former co-workers. While I am strongly convinced that there is a lot of values in 
having multi-disciplinary teams of data scientists, machine learning engineers and software engineers working closely together,
I am also aware that it is not always the optimal organisation.

In this blog post, I will try to summarize what is the ideal organisation for a team dedicated to using Machine Learning 
in a production setting, and we then will see what are some limitations of this way of doing things. Finally, I will list 
some pragmatic workarounds to make the best of what is, and not what should be. 

## An ideal organisation

I will suppose in the following that you are using Machine Learning to build a product, and not doing Data Science for 
advanced analytics. That entails that it will be reused several times on new data (but that can be the case too if you 
regenerate a report monthly for example), but more importantly, that the model you have created will have some kind of 
integration with the rest of your codebase (either it's called as an independent API, or it becomes part of your codebase
more directly). 

The first way of doing this is to have a team of data scientists building pipelines, and then handing over the produced 
models to a team of software engineers to implement the productionised version. This option has obvious advantages: 
you can have specialists focusing on what they do best, the production implementation is independent of the training 
pipeline and can be more efficient because it does not have to care for the training constraints (batch vs online notably).
There are also some major drawbacks: it adds a lot of friction to the delivery process, handover can be lengthy and 
frustrating, the risk of bugs is doubled because the implementation is done twice, ect... It can lead to situations where
models are sitting for months or even years in the fridge, waiting for someone from the software engineering team
to have some bandwidth to deal with it. Even when it is prioritised, it can take up to 6 months of back and forth for the 
developers to understand what each feature is representing, match whatever data source was used during modeling to what 
is available in production, implement the predictor in itself, and get both implementations to match. Some of these 
problems can be alleviated if you have a very solid data science platform in place (feature stores, so you don't have to
reimplement feature extraction and cleaning, reproducible training pipelines helping you with the QA process...), but the
friction of having two separate teams of people with different objectives collaborating is harder to mitigate.

An alternative is to give back more agency to your data scientists and set up some infrastructure so that they can deploy
things in production themselves. It might involve packaging everything in a Docker container, 

## Real life limitations


## Pragmatic compromises
