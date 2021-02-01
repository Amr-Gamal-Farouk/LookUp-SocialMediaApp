const functions = require("firebase-functions");
//const admin =require('firebase-admin');
//admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

//exports.onCreateFollower= functions.firestore
//.doc("/followers/{userId}/userFollowers/{followerId}")
//.onCreate((snapshot, context)=>{
//
//console.log("@@@ created ", snapshot.data());
//
//const userId=context.params.userId;
//const followerId=context.params.followerId;
//
//const followedUserPostPostsRef = admin
//.firestore()
//.collection('posts')
//.doc(userId)
//.collection('userPosts');
//
//const timeLinePostsRef = admin
//.firestore()
//.collection('timeLine')
//.doc(followerId)
//.collection('timeLinePosts');
//
//
//const querySnapshot = await followedUserPostPostsRef.get();
//
//
//querySnapshot.forEach(doc =>{
//if(doc.exist){
//const postId=doc.id;
//const postData = doc.data();
//timeLinePostsRef.doc(postId).set(postData);
//}
//})
//
//})