# MP4Chonks

HLS (and possibly DASH?) streams have the ability to stream mp4 files, but in
a special way; an initial `mp4` file is created that contains nothing but some
header data for the following file chunks (stuff like frame size, tracks, what
the tracks do, timescale, etc). Then the actual video data is split over
subsequent `m4s` files.

I wanted to be able to rebuild my hls streams on demand and that requires being
able to determine the duration of each `m4s` file individually (with help from
the `mp4` file). It turns out that `m4s` files are basically just extensions
of the `mp4` format.

So, this library has the ability to parse mp4/m4s file combinations and glean
information from the stream.

As mentioned, my purpose was simply to get the duration, so once I was able to
do that, I stopped. However, I architected in a way that should easily extend
to the rest of the format (both `mp4` and `m4s`. Additionally, it appears that
there may be some additional methods to store (and therefore, derive) duration
information in these files that I didn't implement, but this works for my
needs.

Almost everything in this repo is derived from [these](https://web.archive.org/web/20180219054429/http://l.web.umkc.edu/lizhu/teaching/2016sp.video-communication/ref/mp4.pdf) [pdfs](https://app.box.com/s/5nliqsqltj8ym18bvlqtigpwzaey9duq)
(the latter of which is from [this post](https://videonerd.website/84/)). There
are some atoms (boxes/chunks) that appear in the files that aren't well
documented in these resources (at elast `tfdt`), so it might be worth
investigating some others. I would have included the pdfs in the repo, but I
don't know about the IP/copyright of these papers, I just know that my code is
freely available here to use, improve, or insult and hurt my feelings. I
imagine that it would also be useful as a resource to help understand the
format. Let me know if you use it or have some additions!