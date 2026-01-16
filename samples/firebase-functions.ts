// Sample-only excerpt for public presentation. Not the full backend code.

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import crypto from "crypto";

admin.initializeApp();

type RegisterBeginResponse = {
  uid: string;
  challenge: string;
  userID: string;
  rpID: string;
  rpName: string;
};

type SignInFinishResponse = {
  uid: string;
  displayName: string;
  memberSince: string;
  customToken: string;
};

const rpID = "embera.coffee";
const rpName = "EMBERA";

const randomChallenge = (): string => {
  return crypto.randomBytes(32).toString("base64url");
};

export const registerBegin = functions.https.onCall(async (data): Promise<RegisterBeginResponse> => {
  const displayName = String(data?.displayName ?? "Guest");
  const user = await admin.auth().createUser({ displayName });
  const challenge = randomChallenge();

  return {
    uid: user.uid,
    challenge,
    userID: user.uid,
    rpID,
    rpName,
  };
});

export const signInFinish = functions.https.onCall(async (data): Promise<SignInFinishResponse> => {
  const uid = String(data?.uid ?? "");
  const user = await admin.auth().getUser(uid);
  const customToken = await admin.auth().createCustomToken(uid);

  return {
    uid: user.uid,
    displayName: user.displayName ?? "EMBERA Member",
    memberSince: new Date(user.metadata.creationTime ?? Date.now()).toISOString(),
    customToken,
  };
});
