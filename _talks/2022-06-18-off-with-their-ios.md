---
title: “Off with their I/Os!” - or how to contain madness by isolating your code 
conference: PyData London 2022
---
Engulfed in a tedious refactoring of your code, you’re adding the 7th layer of 
mocks to a test when you realise something must have gone wrong somewhere, but what?
You’ve written readable code, split into functions and classes to avoid long chunks
of code, and yet, every time, you end up with hardly testable code, a test suite 
that runs for hours, functions with seventeen arguments, and you wonder if it’s 
you mocking the code or the code mocking you.

Follow the white rabbit with me to learn about usual problems of code organization
and I/O architecture, and some tricks on how to handle I/Os and dependencies 
isolation. We might encounter a bit of SOLID advice, and maybe even a nice hat!

This talk will help you understand the benefits of good architecture, with a focus
on isolating your I/O (inputs/ outputs) and other third-party dependencies, and 
guide through how to achieve it in practice, from simpler to more complex cases. 
I will present good practices coming from software engineering, with a focus on 
applying them to a data science context.

<div class="iframe-wrapper">
    <iframe width="560" height="315" 
src="https://www.youtube.com/embed/8sFG23k2FJ0" 
title="YouTube video player" frameborder="0" 
allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen>
</iframe>
</div>

<div class="iframe-wrapper">
<iframe 
    title="PyData London slides" frameborder="0" 
    src="//sdg.jlbl.net/slides/architecture-principles-for-datascientists/index.html">
</iframe>
</div>