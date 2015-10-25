## LazyWeather-for-iOS

Thanks for your interest! WeatherLazy is in Beta!

If you'd like to test it out yourself, send an email to johnblanier@gmail.com and I can send you an Apple Testflight invitation!

## Who We Are

WeatherLazy Team consists of UC Santa Barbara Students John B. Lanier, and Arthur Pan (check us out under "contributors")

We spent late September and early October researching iOS and have been working on WeatherLazy since.

## What it Does

WeatherLazy uses the Dark Sky Forecast API (https://developer.forecast.io/) to grab json weather data in the background and schedule iOS notifications containing daily forecasts according to the user's settings. Users can specify to never recieve notifications, recieve them evey day at a chosen time, or at that time but only on days with at least a specific, chosen percent chance of rain.

WeatherLazy is geared towards people who don't have (or don't want to have) a habit of checking the weather. With WeatherLazy, people can be informed when the rain might mess up their schedules without checking the weather themselves.

Currently, WeatherLazy uses the iOS background fetch feature to keep itself updated. Even though WeatherLazy schedules (or reschedules) notifications up to a week in advance for redundancy, we've learned that background fetch is not a reliable way have our app work without being open for long periods of time. Consequentially, we are now learning how to implement push-notifcation services to keep the app sliently and reliably updating in the background.

Check back in a few weeks to our new push-notification powered version of WeatherLazy!
