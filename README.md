<h1 align="center">
    <br>
    Music App Flutter
</h1>
<h4 align="center">
 A music app with Flutter and Firebase.
</h4>

<p align="center">
  <img alt="shields.io" src="https://img.shields.io/github/license/salvadordeveloper/TikTok-Flutter" />
  <img alt="shields.io" src="https://img.shields.io/github/issues/salvadordeveloper/TikTok-Flutter" />
  <img alt="shields.io" src="https://img.shields.io/github/stars/salvadordeveloper/TikTok-Flutter?style=social" />
  <img alt="shields.io" src="https://img.shields.io/youtube/views/sMKg6ILYgv0?style=social" />
</p>
<br/>
<p align="center">


</p>

<p align="center">
    <img src="https://scontent.fsgn2-7.fna.fbcdn.net/v/t1.15752-9/462551307_3757335217837847_8483666674138587353_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=9f807c&_nc_eui2=AeFYsSIY2BI1vbZ8Pcc75LMTuweQOALLEWC7B5A4AssRYPIHZ6cjii0PKeE212MN5jMiSblDLxZ-H10PWLr752hc&_nc_ohc=a0b9PTiXeg8Q7kNvgGOa1wd&_nc_zt=23&_nc_ht=scontent.fsgn2-7.fna&_nc_gid=AmJrre08ThKLv8RKnOcW0of&oh=03_Q7cD1QF-4YEsUdQTXGUEAG4JFRLiCHaOftuDFaHMVyD3aN-Xww&oe=6743348F" alt="drawing"   width="170"/>
    <img src="https://scontent.fsgn2-10.fna.fbcdn.net/v/t1.15752-9/462538150_8837328519663561_54299483891190732_n.jpg?_nc_cat=109&ccb=1-7&_nc_sid=9f807c&_nc_eui2=AeGEozI66t7jaBEGBayCcfrpmwHwVhxVHlWbAfBWHFUeVXJegvZSVSMaJ7dNw2My45LWfz-pWksnvEB4BGLHfrob&_nc_ohc=hiWDrnipagEQ7kNvgE7ZFX5&_nc_zt=23&_nc_ht=scontent.fsgn2-10.fna&_nc_gid=AmJrre08ThKLv8RKnOcW0of&oh=03_Q7cD1QGK43pDv0xpeyLPT3ICpfz8lvpwWgPIVgV-wT5jfZv7ow&oe=67434CAB" alt="drawing"   width="170"/>
    <img src="https://scontent.fsgn2-11.fna.fbcdn.net/v/t1.15752-9/462537672_424291520714051_4774101755731657238_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=9f807c&_nc_eui2=AeHDQpTkUo99KOvSmZJxoJEaTvxVAR4u4lJO_FUBHi7iUrLKpHlpXj86NthMP26ItGoAbh8rm2zfVkZqaI1SlkRy&_nc_ohc=n50U_zrz51YQ7kNvgEU0o5C&_nc_zt=23&_nc_ht=scontent.fsgn2-11.fna&_nc_gid=AmJrre08ThKLv8RKnOcW0of&oh=03_Q7cD1QE4D6TozBDN7CkSFdBbpksxKYye1bfWA6QMLDSfO-cYNA&oe=67434300" alt="drawing"   width="170"/>
    <img src="https://scontent.fsgn2-6.fna.fbcdn.net/v/t1.15752-9/462548766_1547953785917727_4566983958714281876_n.jpg?_nc_cat=111&ccb=1-7&_nc_sid=9f807c&_nc_eui2=AeF9V_DtKA5phNXzlGSKbDdYMAnnNHoIPoEwCec0egg-gcZ2fiP27LdFO8cbF1kmzVC1EnfVwxI_UKeueAqqrYd2&_nc_ohc=iTHgx4tpkJkQ7kNvgGtjT2Z&_nc_zt=23&_nc_ht=scontent.fsgn2-6.fna&_nc_gid=AmJrre08ThKLv8RKnOcW0of&oh=03_Q7cD1QE6pMmbqfnXxFMQ3UHxe-Q7r0dhn5fGkn5g3C7632yVvQ&oe=674337B5" alt="drawing"   width="170"/>
<img src="https://scontent.fsgn2-10.fna.fbcdn.net/v/t1.15752-9/462538203_1082536466906501_5884413400571758828_n.jpg?_nc_cat=109&ccb=1-7&_nc_sid=9f807c&_nc_eui2=AeFFZ59x1PT-f7AiOELpEX1WxQPW9m7tX8TFA9b2bu1fxKdQfa42zUKfh76DBuGKCdgz67-jApbO4OplvHa9MQjw&_nc_ohc=mWLRs5dK9_4Q7kNvgHuuJUh&_nc_zt=23&_nc_ht=scontent.fsgn2-10.fna&_nc_gid=AmJrre08ThKLv8RKnOcW0of&oh=03_Q7cD1QFjdCQzHyGqhOu5eXhuJs4iIdJZd1N3KTz23WNmAjUUvA&oe=67434605" alt="drawing"   width="170"/>

</p>

## Features
- User Authentication and Profile Management
- Upload, store, and stream music from Firebase Storage
- Add songs to favorites and display personalized lists
- Mini Player with background audio playback support
- Dynamic music search with partial matching
- Track position and duration of songs for seamless playback
## Libraries Used
- audioplayers: for audio playback
- firebase_auth: for user authentication
- cloud_firestore: to store and retrieve user and song data
- firebase_storage: to manage and store song files and cover images
- provider: for state management
- shared_preferences: to manage local user settings

## Video demo
https://github.com/user-attachments/assets/5a55a892-7449-41e8-b34a-14d2ae85b212

## Database Structure

The app uses Firestore and Firebase Storage:
- Firestore: Stores user data and metadata for songs (e.g., song titles, artists, cover images).
- Firebase Storage: Stores song audio files and cover images.


## TODO

- Implement advanced search and filtering
- Improve UI for the mini-player
- Add song recommendation system
- Enable users to upload music directly from the app


## Changelog

01/10/2024
- Initial Release: Basic player, authentication, and music streaming setup
- Added favorite songs feature and basic playback controls

10/10/2024

- Added mini-player and background playback support

20/10/2024
- Added dark mode support and improved UI
