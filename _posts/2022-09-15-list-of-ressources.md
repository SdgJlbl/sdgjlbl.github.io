---
title:  "List of useful resources"
---
There are talks or blog posts you keep returning too. Either because you want to share them with someone else, or 
because you periodically feel like you want to re-read or re-watch them, and every time, you get a deeper 
understanding of what is discussed. 

In this blog post, I want to curate a list of resources that have had a long-standing effect on my engineering practice; 
I hope it will be useful to you, I know it will be useful to me. It might be updated in the future with new discoveries.

First, let's begin with a talk that has really helped me shape my vision of how to architecture code: 
Gary Bernhardt's [talk on boundaries](https://www.destroyallsoftware.com/talks/boundaries). 
It presents the "functional core and imperative shell" principle for organising your code, and it is the cleanest
explanation I know of how to articulate the functional programming principles in a real-world setting. 

Speaking of functional versus object-oriented programming, the blog post 
["Don’t write stupid classes"](https://eev.ee/blog/2013/03/03/the-controller-pattern-is-awful-and-other-oo-heresy/)
is explaining in a great way when and how classes should be used. 

For a more Python-focused explanation, you should absolutely read Hynek Schlawack's 
[take on subclassing](https://hynek.me/articles/python-subclassing-redux/). (You can read the rest of his blog while 
you're at it). 

To conclude on architecture, ["Mock hell"](https://www.youtube.com/watch?v=CdKaZ7boiZ4), a talk by Edwin Jung,
is exposing best practices from the lens of testing. The idea is that code that is hard to test well 
(complex logic in unit tests or the presence of mocks) is usually not organised in the best possible way.
You can think of it as a "code smell", a sign that something might be worth looking into it. 


All the above presents general principles and concrete examples of how to organise your code; but what about documentation?
Good documentation is an essential part of all projects, and it's all too often neglected, and we all know that. 
But even with the best of intentions, it may be a daunting task to know how to start. 
Daniele Procida has devised a framework, called [Diátaxis](https://diataxis.fr/) to help with organising your documentation: 
each piece of documentation falls into one, and only one, of the four categories: 
tutorials (learning-oriented), how-to guides (problem-oriented), explanations (understanding-oriented) 
and API reference (information-oriented). Using this paradigm, you can ensure that your end users have all the information
they need, but no more than the information they need, at the right time in their journey. 
You can learn more in [this talk](https://www.youtube.com/watch?v=t4vKPhjcMZg).

If we leave the realm of pure software engineering to venture into machine learning territory, 
you probably want to check out this talk by Vincent Warmerdam on 
[how to constraint Artificial Stupidity](https://www.youtube.com/watch?v=Z8MEFI7ZJlA).
No matter what domain area you are working in, or what kind of algorithms you are using, this talk raises typical pitfalls
you might encounter while developing machine learning pipelines, and what you can do to mitigate those problems, in 
particular in applications where AI-driven decisions might have very real impact on people when used in production, 
and fairness matters.
On a side note, Vincent also has a nice website dedicated to programming learning ressources [calmcode.io](https://calmcode.io/).

Staying with the topic of fairness when designing machine learning algorithms, Adrin Jalali's 
[talk](https://www.youtube.com/watch?v=9uLDyK8jKYc) asks all the right questions. It is accessible to everyone, including
non-technical audience, and it shows how the problem of designing fair algorithms goes beyond considerations of gender
and skin color (and how it is as much a social as a technical problem too).

If you're interested in the problematics of data privacy, Katharine Jarmul has been giving great talks and workshops on 
this topic; for example, this [talk](https://www.infoq.com/presentations/privacy-fair-algorithms/) from 2019 on how 
privacy is also linked to fairness. And she's writing a 
[book on data privacy](https://www.oreilly.com/library/view/practical-data-privacy/9781098129453/), out in 2023. 

Moving outside of ethics in data science, Marysia Winkels gave a super interesting 
[talk on data-centric AI](https://www.youtube.com/watch?v=vgtdPwUrP5I), or why we should focus on the "data" in "data science".
It's one of those talks that crystallises ideas floating around and packages them in a neat way for further practical use. 

And to finish on a meta note, Saron Yitbarek gave a great [talk about giving great talks](https://www.youtube.com/watch?v=AzVr_nsKoZs)
and storytelling in tech talks. It is packed with great advice for first-time speakers, and others.

That's all for now, I hope you enjoyed these resources!

