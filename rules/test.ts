/// <reference path='../node_modules/mocha-typescript/globals.d.ts' />
import * as firebase from "@firebase/testing";
import * as fs from "fs";
import { assert } from "chai";
import { FieldPath, Timestamp, Firestore } from "@google-cloud/firestore";

/*
 * ============
 *    Setup
 * ============
 */
const projectIdBase = "andalom-emulator-" + Date.now();

const rules = fs.readFileSync("rules/firestore.rules", "utf8");

const testUserId = "alice";
const testUserData = {
  fcmToken: "FCM_TOKEN",
  subscription: {
    numberPlate: "AB-CD 192",
    createdAt: "request.time"
  },
  updatedAt: "request.time",
  createdAt: firebase.firestore.FieldValue.serverTimestamp()
};

const testReportId = "reportId-1";
const testReportData = {
  numberPlate: "EF-GH 234",
  message: "Test Message",
  reporter: {
    id: testUserId,
  },
  updatedAt: "request.time",
  createdAt: firebase.firestore.FieldValue.serverTimestamp()
};

const validNumberplates = [
  "AB-CD 123",
  "ECK AN 343",
  "ECK   SD   343",
  "K-D 1",
]

const invalidNumberplates = [
  "    ",
  "INVALID",
  "AB-CDE 32",
  "AB-HF 04"
]

// Run each test in its own project id to make it independent.
let testNumber = 0;

/**
 * Returns the project ID for the current test
 *
 * @return {string} the project ID for the current test.
 */
function getProjectId() {
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

@suite
class AndalomUserCreate extends TestingBase {

  @test
  async "require users to log in before creating user data"() {
    const db = authedApp(null);

    const profile = db.collection("users").doc(testUserId);
    await firebase.assertFails(profile.set(testUserData));
  }

  @test
  async "deny creation of other user than themselves"() {
    const db = authedApp({ uid: testUserId });

    const profile = db.collection("users").doc("other-user");
    await firebase.assertFails(profile.set(testUserData));
  }

  @test
  async "should enforce the createdAt date in user data"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    await firebase.assertFails(ref.set({
      ...testUserData,
      createdAt: "invalid timestamp",
    }));

    let noCreatedAt = { ...testUserData };
    delete noCreatedAt.createdAt

    await firebase.assertFails(ref.set(noCreatedAt));
    await firebase.assertSucceeds(ref.set(testUserData));
  }

  @test
  async "should enforce the updatedAt date in user data"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    await firebase.assertFails(ref.set({
      ...testUserData,
      updatedAt: "invalid timestamp",
    }));

    let noUpdatedAt = { ...testUserData };
    delete noUpdatedAt.updatedAt

    await firebase.assertFails(ref.set(noUpdatedAt));
    await firebase.assertSucceeds(ref.set(testUserData));
  }

  @test
  async "should deny empty data"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    await firebase.assertFails(ref.set({}));
  }

  @test
  async "should deny null number plate subscription"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    const nullSubscription = { ...testUserData, subscription: null };

    await firebase.assertFails(ref.set(nullSubscription));
  }

  @test
  async "should deny additional unknown fields"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    await firebase.assertFails(ref.set({
      ...testUserData,
      foo: "bar"
    }));
  }

  @test
  async "should deny additional unknown subscription fields"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    await firebase.assertFails(ref.set({
      ...testUserData,
      subscription: {
        ...testUserData.subscription,
        foo: "bar",
      }
    }));
  }

  @test
  async "should enforce the createdAt date in user subscription data"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    await firebase.assertFails(ref.set({
      ...testUserData,
      subscription: {
        ...testUserData.subscription,
        createdAt: "invalid timestamp",
      }
    }));

    let noCreatedAt = {
      ...testUserData,
      subscription: {
        numberPlate: "AB-CD 123"
      }
    };

    await firebase.assertFails(ref.set(noCreatedAt));
    await firebase.assertSucceeds(ref.set(testUserData));
  }


  @test
  async "can create user with null fcm token but not with empty"() {
    const db = authedApp({ uid: testUserId });
    var ref = db.collection("users").doc(testUserId);

    await firebase.assertFails(ref.set({
      ...testUserData,
      "fcmToken": "",
    }));

    const noFCM = { ...testUserData };
    delete noFCM.fcmToken
    await firebase.assertFails(ref.set(noFCM));

    await firebase.assertSucceeds(ref.set({
      ...testUserData,
      "fcmToken": null,
    }));
  }

  @test
  async "number plate should match regular expression"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    for (let i = 0; i < invalidNumberplates.length; i++) {
      const numberPlate = invalidNumberplates[i];
      await firebase.assertFails(ref.set({
        ...testUserData,
        subscription: {
          ...testUserData.subscription,
          numberPlate: numberPlate,
        }
      }));
    }

    const valids = [...validNumberplates]
    for (let i = 0; i < valids.length; i++) {

      const db = authedApp({ uid: testUserId + i });
      const ref = db.collection("users").doc(testUserId + i);

      const numberPlate = valids[i];
      await firebase.assertSucceeds(ref.set({
        ...testUserData,
        subscription: {
          ...testUserData.subscription,
          numberPlate: numberPlate,
        }
      }));
    }
  }

  @test
  async "test valid and invalid subscription updates"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    const invalidSubscriptions = [
      { subscription: {}, },
      { subscription: { createdAt: "request.time" }, },
      { subscription: { numberPlate: null } },
      { subscription: { numberPlate: "" } },
      { subscription: { numberPlate: "RD-WE 325" } },
      { subscription: { numberPlate: "RD-WE 325", createdAt: null } },
      { subscription: { numberPlate: "INVALID", createdAt: "request.time" } },
      // The following should fail because it is the same number plate, so the createdAt field should stay constant
      // { subscription: { numberPlate: testUserData.subscription.numberPlate, createdAt: "request.time" }, },
      { subscription: { foo: "bar", bar: "baz" } },
    ]

    for (let i = 0; i < invalidSubscriptions.length; i++) {
      await firebase.assertFails(ref.set({ ...testUserData, ...invalidSubscriptions[i] }));
    }

    const validSubscriptionUpdates = [
      { subscription: { numberPlate: "RD-WE 325", createdAt: "request.time" }, },
      { subscription: { numberPlate: "LGF-HG 7", createdAt: "request.time" }, },
      { subscription: { numberPlate: null, createdAt: null }, },
    ]

    for (let i = 0; i < validSubscriptionUpdates.length; i++) {
      const db = authedApp({ uid: testUserId + i });
      const ref = db.collection("users").doc(testUserId + i);
      await firebase.assertSucceeds(ref.set({ ...testUserData, ...validSubscriptionUpdates[i] }));
    }
  }
}

@suite
class AndalomUserUpdate extends TestingBase {
  async before() {
    await super.before();

    const db = adminApp();
    const ref1 = db.collection("users").doc(testUserId);
    await ref1.set(testUserData)

    const ref2 = db.collection("users").doc("other-user");
    await ref2.set(testUserData)
  }

  @test
  async "require users to log in before updating user data"() {
    const db = authedApp(null);
    const ref = db.collection("users").doc(testUserId);

    await firebase.assertFails(ref.update(testUserData));
  }

  // Comment in as soon as https://github.com/firebase/firebase-tools/issues/1073 is fixed
  @test
  // async "enforce an update of the updatedAt field"() {
  //   const db = authedApp({ uid: testUserId });
  //   const ref = db.collection("users").doc(testUserId);

  //   const validSubscriptionUpdate = {
  //     subscription: {
  //       numberPlate: "RD-WE 325",
  //       createdAt: "request.time"
  //     },
  //     updatedAt: "request.time"
  //   };

  //   const invalidSubscriptionUpdate = {
  //     subscription: {
  //       numberPlate: "RD-WE 325",
  //       createdAt: "request.time"
  //     },
  //   };

  //   await firebase.assertFails(ref.update(invalidSubscriptionUpdate));
  //   await firebase.assertSucceeds(ref.update(validSubscriptionUpdate));
  // }

  @test
  async "test valid and invalid subscription updates"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);
    // const update = { updatedAt: firebase.firestore.FieldValue.serverTimestamp() };
    const update = { updatedAt: "request.time" };

    const invalidSubscriptionUpdates = [
      { subscription: {}, },
      { subscription: { createdAt: "request.time" }, },
      { subscription: { numberPlate: null } },
      { subscription: { numberPlate: "" } },
      { subscription: { numberPlate: "RD-WE 325" } },
      { subscription: { numberPlate: "RD-WE 325", createdAt: null } },
      { subscription: { numberPlate: "INVALID", createdAt: "request.time" } },
      // The following should fail because it is the same number plate, so the createdAt field should stay constant
      // { subscription: { numberPlate: testUserData.subscription.numberPlate, createdAt: "request.time" }, },
      { subscription: { foo: "bar", bar: "baz" } },
    ]

    for (let i = 0; i < invalidSubscriptionUpdates.length; i++) {
      const newSubscription = invalidSubscriptionUpdates[i];
      await firebase.assertFails(ref.update({ ...update, ...newSubscription }));
    }

    const validSubscriptionUpdates = [
      { subscription: { numberPlate: "RD-WE 325", createdAt: "request.time" }, },
      { subscription: { numberPlate: "LGF-HG 7", createdAt: "request.time" }, },
      { subscription: { numberPlate: null, createdAt: null }, },
    ]

    for (let i = 0; i < validSubscriptionUpdates.length; i++) {
      const newSubscription = validSubscriptionUpdates[i];
      await firebase.assertSucceeds(ref.update({ ...update, ...newSubscription }));
    }
  }

  @test
  async "deny update of other user"() {
    const db = authedApp({ uid: testUserId });
    const ref1 = db.collection("users").doc(testUserId);
    const ref2 = db.collection("users").doc("other-user");

    await firebase.assertSucceeds(ref1.update({}));
    await firebase.assertFails(ref2.update({}));
  }

  @test
  async "deny additional unknown fields"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    await firebase.assertFails(ref.update({
      foo1: "bar",
      foo2: "bar",
      foo3: "bar",
    }));

    await firebase.assertFails(ref.update({
      ...testUserData,
      foo: "bar",
    }));
  }

  @test
  async "can update FCM token"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    const adminDb = adminApp();
    const ref1 = adminDb.collection("users").doc("noFCM");
    const noFCM = { ...testUserData, fcmToken: null };
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

  @test
  async "deny changing createdAt field"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    await firebase.assertFails(ref.update({
      ...testUserData,
      createdAt: "request.time2",
    }));
  }
}

@suite
class AndalomUserRead extends TestingBase {
  async before() {
    await super.before();

    const db = adminApp();
    const ref = db.collection("users").doc(testUserId);
    await ref.set(testUserData)
  }

  @test
  async "require users to log in before reading user data"() {
    const db = authedApp(null);
    const ref = db.collection("users").doc(testUserId);

    await firebase.assertFails(ref.get());
  }

  @test
  async "users can read their own data"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc(testUserId);

    await firebase.assertSucceeds(ref.get());
  }

  @test
  async "users can not read other users data"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("users").doc("otherUsersId");

    await firebase.assertFails(ref.get());
  }
}

@suite
class AndalomReportsCreate extends TestingBase {
  @test
  async "users can only create reports when they are logged in"() {
    const db = authedApp(null);
    const ref = db.collection("reports").doc(testReportId)

    await firebase.assertFails(ref.set(testReportData));
  }

  @test
  async "logged in users can create test report"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports").doc(testReportId)

    await firebase.assertSucceeds(ref.set(testReportData));
  }

  @test
  async "should enforce the createdAt date in report data"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports").doc(testReportId);

    await firebase.assertFails(ref.set({
      ...testReportData,
      createdAt: "invalid timestamp",
    }));

    let noCreatedAt = { ...testReportData };
    delete noCreatedAt.createdAt

    await firebase.assertFails(ref.set(noCreatedAt));
    await firebase.assertSucceeds(ref.set(testReportData));
  }

  @test
  async "should enforce the updatedAt date in report data"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports").doc(testReportId)

    await firebase.assertSucceeds(ref.set(testReportData));

    await firebase.assertFails(ref.set({
      ...testReportData,
      updatedAt: "invalid timestamp",
    }));

    let noUpdatedAt = { ...testReportData };
    delete noUpdatedAt.updatedAt

    await firebase.assertFails(ref.set(noUpdatedAt));
  }

  @test
  async "prevent report creation in the name of someone else"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports").doc(testReportId);

    await firebase.assertFails(ref.set({
      ...testReportData,
      reporter: {
        id: "other-user",
      }
    }));
  }

  @test
  async "deny additional unknown fields"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports").doc(testReportId);

    await firebase.assertFails(ref.set({
      ...testReportData,
      foo: "bar",
    }));

    let noUpdatedAtField = { ...testReportData }
    delete noUpdatedAtField.updatedAt
    await firebase.assertFails(ref.set({
      ...noUpdatedAtField,
      foo: "bar",
    }));
  }

  @test
  async "enforce message type to be string"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports").doc(testReportId);

    await firebase.assertFails(ref.set({
      ...testReportData,
      message: 23,
    }));
  }

  @test
  async "enforce numberPlate type to be string"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports").doc(testReportId);

    await firebase.assertFails(ref.set({
      ...testReportData,
      numberPlate: 234,
    }));
  }

  @test
  async "enforce reporter type to be defined map"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports").doc(testReportId);

    await firebase.assertFails(ref.set({
      ...testReportData,
      reporter: {
        ...testReportData.reporter,
        foo: "bar"
      },
    }));

    await firebase.assertFails(ref.set({
      ...testReportData,
      reporter: {
        foo: "bar"
      },
    }));
  }

  @test
  async "enforce presence of number plate"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports").doc(testReportId);

    await firebase.assertFails(ref.set({
      ...testReportData,
      numberPlate: "",
    }));

    let noNumberPlate = { ...testReportData }
    delete noNumberPlate.numberPlate
    await firebase.assertFails(ref.set(noNumberPlate));
  }

  @test
  async "number plate should match regular expression"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports").doc(testReportId);

    for (let i = 0; i < invalidNumberplates.length; i++) {
      const numberPlate = invalidNumberplates[i];
      await firebase.assertFails(ref.set({
        ...testReportData,
        numberPlate: numberPlate,
      }));
    }

    const reportsRef = db.collection("reports")

    for (let i = 0; i < validNumberplates.length; i++) {
      await firebase.assertSucceeds(reportsRef.add({
        ...testReportData,
        numberPlate: validNumberplates[i],
      }));
    }
  }
}

@suite
class AndalomReportsList extends TestingBase {
  async before() {
    await super.before();

    const db = adminApp();
    const usersRef = db.collection("users").doc(testUserId)
    await usersRef.set(testUserData)

    const reportsRef = db.collection("reports")

    // Report from test user to EF-GH 234
    await reportsRef.doc(testReportId).set(testReportData);

    // Report from other user to test user (AB-CD 192)
    await reportsRef.add({
      ...testReportData,
      numberPlate: "AB-CD 192",
      reporter: {
        id: "other-user"
      }
    })

    // Report from other user to test user (AB-CD 192), but before test user
    // has subscribed to that numberplate
    await reportsRef.add({
      ...testReportData,
      numberPlate: "AB-CD 192",
      reporter: {
        id: "other-user"
      },
      createdAt: firebase.firestore.Timestamp.fromMillis(1),
    })

    // Report from other user to other user...
    await reportsRef.add({
      ...testReportData,
      numberPlate: "YY-ZZ 999",
      reporter: {
        id: "other-user"
      }
    })
  }

  @test
  async "users can only query reports when they are logged in"() {
    const db = authedApp(null);
    const ref = db.collection("reports")

    await firebase.assertFails(ref.get());
  }

  @test
  async "users cannot query all reports"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports");

    await firebase.assertFails(ref.get());
  }

  @test
  async "users can query all reports he/she has subscribed to from that date on in descending order"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports");

    await firebase.assertFails(ref
      .where("numberPlate", "==", testUserData.subscription.numberPlate)
      .get())


    await firebase.assertSucceeds(ref
      .where("numberPlate", "==", testUserData.subscription.numberPlate)
      .where("createdAt", ">=", "request.time")// user.data()["createdAt"].toDate())
      .orderBy("createdAt", "desc")
      .get())

    // assert.equal(reports.size, 1);
  }

  @test
  async "users can query all reports he/she has created regardless of dates"() {
    const db = authedApp({ uid: testUserId });
    const ref = db.collection("reports");

    const reports = await ref.where("reporter.id", "==", testUserId).get();

    assert.equal(reports.size, 1);
  }
}