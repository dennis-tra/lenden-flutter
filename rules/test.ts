/// <reference path='../node_modules/mocha-typescript/globals.d.ts' />
import * as firebase from "@firebase/testing";
import * as fs from "fs";

/*
 * ============
 *    Setup
 * ============
 */
const projectIdBase = "lenden-emulator-" + Date.now();

const rules = fs.readFileSync("rules/firestore.rules", "utf8");

const testUserId1 = "alice";
const testUserId2 = "bob";

const testUserData1 = {
  "fcmToken": "TEST_FCM_TOKEN_1",
};
const testUserData2 = {
  "fcmToken": "TEST_FCM_TOKEN_2",
};

const testPairingsId = "testpairingid"
const testPairingsData = {
  "user_ids": {
    [testUserId1]: true,
    [testUserId2]: true
  }
}


// Run each test in its own project id to make it independent.
let testNumber = 0;

/**
 * Returns the project ID for the current test
 *
 * @return {string} the project ID for the current test.
 */
function getProjectId(): string {
  return `${projectIdBase}-${testNumber}`;
}

/**
 * Creates a new app with authentication data matching the input.
 *
 * @param {object} auth the object to use for authentication (typically {uid: some-uid})
 * @return {object} the app.
 */
function authedApp(auth) {
  return firebase
    .initializeTestApp({
      projectId: getProjectId(),
      auth: auth
    })
    .firestore();
}


/**
 * Creates a new app with admin privileges.
 *
 * @return {object} the app.
 */
function adminApp() {
  return firebase
    .initializeAdminApp({
      projectId: getProjectId(),
    })
    .firestore();
}

/*
 * ============
 *  Test Cases
 * ============
 */
class TestingBase {
  async before() {
    // Create new project ID for each test.
    testNumber++;
    await firebase.loadFirestoreRules({
      projectId: getProjectId(),
      rules: rules
    });
  }

  async after() {
    await Promise.all(firebase.apps().map(app => app.delete()));
  }
}

/*
 * ========================
 *  User CRUD Test Cases
 * ========================
 */
@suite
class LendenUserCreate extends TestingBase {

  @test
  async "require users to log in before creating user data"() {
    const db = authedApp(null);

    const profile = db.collection("users").doc(testUserId1);
    await firebase.assertFails(profile.set(testUserData1));
  }

  @test
  async "deny creation of other user than themselves"() {
    const db = authedApp({ uid: testUserId1 });

    const profile = db.collection("users").doc(testUserId2);
    await firebase.assertFails(profile.set(testUserData1));
  }


  @test
  async "should deny empty data"() {
    const db = authedApp({ uid: testUserId1 });
    const ref = db.collection("users").doc(testUserId1);

    await firebase.assertFails(ref.set({}));
  }

  @test
  async "can create user with null fcm token but not with empty"() {
    const db = authedApp({ uid: testUserId1 });
    const ref = db.collection("users").doc(testUserId1);

    await firebase.assertFails(ref.set({
      ...testUserData1,
      "fcmToken": "",
    }));

    const noFCM = { ...testUserData1 };
    delete noFCM.fcmToken
    await firebase.assertFails(ref.set(noFCM));

    await firebase.assertSucceeds(ref.set({
      ...testUserData1,
      "fcmToken": null,
    }));
  }
}

@suite
class LendenUserRead extends TestingBase {
  async before() {
    await super.before();

    const db = adminApp();
    const ref1 = db.collection("users").doc(testUserId1);
    await ref1.set(testUserData1)

    const ref2 = db.collection("users").doc(testUserId2);
    await ref2.set(testUserData2)
  }

  @test
  async "require users to log in before reading user data"() {
    const db = authedApp(null);
    const ref = db.collection("users").doc(testUserId1);

    await firebase.assertFails(ref.get());
  }

  @test
  async "users can read their own data"() {
    const db = authedApp({ uid: testUserId1 });
    const ref = db.collection("users").doc(testUserId1);

    await firebase.assertSucceeds(ref.get());
  }

  @test
  async "users can not read other users data"() {
    const db = authedApp({ uid: testUserId1 });
    const ref = db.collection("users").doc(testUserId2);

    await firebase.assertFails(ref.get());
  }
}


@suite
class LendenUserUpdate extends TestingBase {
  async before() {
    await super.before();

    const db = adminApp();
    const ref1 = db.collection("users").doc(testUserId1);
    await ref1.set(testUserData1)

    const ref2 = db.collection("users").doc(testUserId2);
    await ref2.set(testUserData2)
  }

  @test
  async "require users to log in before updating user data"() {
    const db = authedApp(null);
    const ref = db.collection("users").doc(testUserId1);

    await firebase.assertFails(ref.update(testUserData1));
  }

  @test
  async "deny update of other user"() {
    const db = authedApp({ uid: testUserId1 });
    const ref1 = db.collection("users").doc(testUserId1);
    const ref2 = db.collection("users").doc(testUserId2);

    await firebase.assertSucceeds(ref1.update({}));
    await firebase.assertFails(ref2.update({}));
  }

  @test
  async "deny additional unknown fields"() {
    const db = authedApp({ uid: testUserId1 });
    const ref = db.collection("users").doc(testUserId1);

    await firebase.assertFails(ref.update({
      foo1: "bar",
      foo2: "bar",
      foo3: "bar",
    }));

    await firebase.assertFails(ref.update({
      ...testUserData1,
      foo: "bar",
    }));
  }

  @test
  async "can update FCM token"() {
    const db = authedApp({ uid: testUserId1 });
    const ref = db.collection("users").doc(testUserId1);

    const adminDb = adminApp();
    const ref1 = adminDb.collection("users").doc("noFCM");
    const noFCM = { ...testUserData1, fcmToken: null };
    await ref1.set(noFCM)

    await firebase.assertFails(ref.update({
      fcmToken: "",
    }));

    await firebase.assertSucceeds(ref.update({
      fcmToken: "FCM_TOKEN_2",
    }));

    await firebase.assertSucceeds(ref.update({
      fcmToken: null,
    }));
  }
}

@suite
class LendenPairingsReadList extends TestingBase {
  async before() {
    await super.before();

    const db = adminApp();
    const ref = db.collection("pairings").doc(testPairingsId);
    await ref.set(testPairingsData)
  }

  @test
  async "require users to log in before reading pairings data"() {
    const db = authedApp(null);
    const ref = db.collection("pairings").doc(testPairingsId);

    await firebase.assertFails(ref.get());
  }

  @test
  async "users can not read another single pairing"() {
    const db = authedApp({ uid: testUserId1 });
    const ref = db.collection("pairings").doc("some-other-id");

    await firebase.assertFails(ref.get());
  }

  @test
  async "users can not list an arbitrary amount of pairings"() {
    const db = authedApp({ uid: testUserId1 });

    await firebase.assertFails(db.collection("pairings").get());
  }

  @test
  async "users can list their own pairings"() {
    const db = authedApp({ uid: testUserId1 });
    const ref = db.collection("pairings").where(`user_ids.${testUserId1}`, "==", true);

    await firebase.assertSucceeds(ref.get());
  }
}