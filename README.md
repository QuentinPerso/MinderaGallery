# MinderaGallery

## Introduction and installation

Here is my answer to the test that was sent. Written in Switf 4.0 on Xcode Version 9.2.  I used cocoapod for Alamofire(+Images), but as I pushed the pod there is normaly no need to run the pod install command.

## Use of frameworks

I used Alamofire and AlamofireImages because they are very convenient frameworks but after reading the email you just sent me I am really scared you might consider it as cheating. In that case I still have some time left so tell me if you want me to redo the test without any framework.

## Use of Storyboards

I used the default suggested xCode new project architecture. Storyboard is a wonderful tool, fast and easy. I tend to separate storyboards files as much as possible and not use so many segues on bigger projects to avoid endless and painfull merge conflicts. (As I don't know how you are working, justifying the use of a storyboard seemed necessary to me 😅)

## Use of INSPhotoGallery

INSPhotoGallery is just the library I used for displaying full screen images. Once again I could have done it without but I like the way they did the interactive transitionning and they handle the zooming in the pictures. If i didn't put it as a pod it's because I slightly changed it in order to use AlamofireImages UIImageView extension default downloader.

## Offline Strategy

As not much was mentionned in the exercise statement for how should be handled the offline, I took the liberty of choosing the following strategy :

### Total transparency on user side

I first wanted to add a selector to chose image to keep offline but it felt like it was way out the app needs. So what I did is just take the last requested images and display them if no network is available (or even if network is available it put it at the beggining of the collection, making the app far more reactive 😊).
As for the large images, I didn't only put in cache the ones that the user opened  (but they are still viewable in full screen as a LargeSquare if not in cache).

### How Is it done

As i said before I used Alamofire to handle all the image loading and caching. Here is to justify my choice :
- [x] Average size of images in LargeSquare : 20000 Bytes, 50 images cached = 1000000 Bytes
- [x] Some of the large images among those 50 as long as cache memory is not filled
- [x] AlamofireImages default cache size = 150 MB ! [doc here](https://github.com/Alamofire/AlamofireImage#image-caching)

So what is done is on "applicationDidEnterBackground" the Application download and cache all the missing images, the last ones the user selected in full screen - if any - stays in cache (indeed default behavior is a FIFO list so I'm sure that at least all the LargeSquare are here)

## Unit tests

I included a few unit test for API call check and Json deserialisation performances.
I hope the code is easily readable and testable enought. If not please tell me as I am always eager to learn from my mistakes !



