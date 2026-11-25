const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onAnswerCreated = functions.firestore
    .document("posts/{postId}/answers/{answerId}")
    .onCreate(async (snap, context) => {
        const answerData = snap.data();
        const postId = context.params.postId;

        // Don't notify if system generates an answer or the user answers their own post
        if (answerData.userId === "system") return null;

        // Fetch the post to find the post author's ID
        const postSnapshot = await admin.firestore().collection("posts").doc(postId).get();
        if (!postSnapshot.exists) {
            console.log("Post does not exist");
            return null;
        }

        const postData = postSnapshot.data();
        const postAuthorId = postData.userId;

        // Do not notify if the author answered their own post
        if (answerData.userId === postAuthorId) {
            console.log("Author answered their own post, skipping notification.");
            return null;
        }

        // Fetch post author's profile
        const userSnapshot = await admin.firestore().collection("users").doc(postAuthorId).get();
        if (!userSnapshot.exists) {
            console.log("User does not exist");
            return null;
        }

        const userData = userSnapshot.data();
        const fcmToken = userData.fcmToken;

        if (!fcmToken) {
            console.log("No FCM token found for user");
            return null;
        }

        // Check if the user has answer notifications enabled
        const receiveAnswerNotif = userData.receiveAnswerNotif !== false; // Default to true if not set
        if (!receiveAnswerNotif) {
            console.log("User disabled answer notifications.");
            return null;
        }

        const message = {
            token: fcmToken,
            notification: {
                title: "New Answer to your Post! 🌿",
                body: `${answerData.userName} just answered your post about ${postData.cropType}.`,
            },
            android: {
                notification: {
                    clickAction: "FLUTTER_NOTIFICATION_CLICK"
                }
            },
            data: {
                postId: postId,
                type: "new_answer"
            }
        };

        try {
            const response = await admin.messaging().send(message);
            console.log("Successfully sent notification:", response);
            return response;
        } catch (error) {
            console.error("Error sending notification:", error);
            return null;
        }
    });
