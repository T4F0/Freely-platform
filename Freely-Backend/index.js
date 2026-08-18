import { ApolloServer } from "@apollo/server";
import { ApolloServerPluginDrainHttpServer } from "@apollo/server/plugin/drainHttpServer";
import express from "express";
import cors from "cors";
import { mergedGQLSchema } from "./lib/schema.js";
import { resolvers } from "./lib/callback.js";
import connectDB from "./lib/connectdb.js";
import verifyToken from "./lib/utils/token.js";
import http from "http";
import { expressMiddleware } from "@apollo/server/express4";
import { makeExecutableSchema } from "@graphql-tools/schema";
import multer from "multer";
import { fileURLToPath } from "url";
import { dirname } from "path";
import passport from "passport";
import { Strategy as GoogleStrategy } from "passport-google-oauth20";
import session from "express-session";
import { client } from "./db/client.js";
import { freelancer } from "./db/freelancer.js";
import signToken from "./lib/utils/sign.js";
import seedJobs from "./lib/seed.js";
import { initializeApp } from "firebase/app";
import {
  getStorage,
  ref,
  getDownloadURL,
  uploadBytesResumable,
} from "firebase/storage";

const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  projectId: process.env.FIREBASE_PROJECT_ID,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.FIREBASE_APP_ID,
};

const firebaseApp = initializeApp(firebaseConfig);
const storage = getStorage(firebaseApp);
const PORT = process.env.PORT || 8000;
const GRAPH_PORT = process.env.GRAPH_PORT || 7000;

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
app.use(verifyToken);
app.use(cors(), express.json());
const schema = makeExecutableSchema({
  typeDefs: mergedGQLSchema,
  resolvers,
});
// const upload = multer({
//   storage: multer.diskStorage({
//     destination: (req, file, cb) => {
//       cb(null, path.join(__dirname, "uploads")); // Set destination folder
//     },
//     filename: (req, file, cb) => {
//       const ext = path.extname(file.originalname);
//       const filename = Date.now().toString(); // Extract filename without extension
//       cb(null, `${filename}${ext || ".unknown"}`); // Add extension if missing
//     },
//   }),
// });

const upload = multer({ storage: multer.memoryStorage() });

app.use(verifyToken);
app.use(cors(), express.json());
// app.use(`/uploads`, express.static(`uploads`));

// upload multiple files
app.post("/uploads", upload.array("files"), async (req, res) => {
  if (!req.files) {
    return res.status(400).send("Please upload at least one file");
  }

  const uploadedFilepaths = [];

  for (const file of req.files) {
    const storageRef = ref(
      storage,
      `uploads/${Date.now().toString() + "  " + file.originalname}`
    );
    const metadata = {
      contentType: file.mimetype,
    };

    const snapshot = await uploadBytesResumable(
      storageRef,
      file.buffer,
      metadata
    );
    const filepath = await getDownloadURL(storageRef);
    uploadedFilepaths.push(filepath);
  }

  res.status(200).send({ uploadedFilepaths });
});

// upload single file
app.post("/upload", upload.single("file"), async (req, res) => {
  if (!req.file) {
    return res.status(400).send("Please upload a file");
  }

  const storageRef = ref(
    storage,
    `uploads/${Date.now().toString() + "  " + req.file.originalname}`
  );
  const metadata = {
    contentType: req.file.mimetype,
  };

  const snapshot = await uploadBytesResumable(
    storageRef,
    req.file.buffer,
    metadata
  );
  const filepath = await getDownloadURL(storageRef);
  console.log(filepath);

  res.status(200).send({ filepath });
});

// -----------------------------------------------------------------------------------------------
const httpServer = http.createServer(app);
const server = new ApolloServer({
  schema,
  plugins: [ApolloServerPluginDrainHttpServer({ httpServer })],
});

await server.start();
app.use(
  "/graphql",
  expressMiddleware(server, {
    context: async ({ req }) => ({ user: req.user }),
  })
);

httpServer.listen(PORT, () => {
  connectDB(process.env.MONGO_URI);
  // seedJobs();
  console.log(
    `Worker ${process.pid} is now running on http://localhost:${PORT}/graphql`
  );
});

// -----------------------------------------------------------------------------------------------
// passport stuff
app.use(passport.initialize());
app.use(
  session({
    secret: process.env.JWT_SECRET,
    resave: false,
    saveUninitialized: true,
  })
);

passport.serializeUser((user, done) => {
  done(null, user);
});

passport.deserializeUser((user, done) => {
  done(null, user);
});

passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: "http://localhost:8000/google/callback",
    },
    async function (access, token, refreshToken, profile, cb) {
      const cuser = await client.findOne({ email: profile._json.email });
      if (!cuser) {
        const fuser = await freelancer.findOne({ email: profile._json.email });
        if (!fuser) {
          return cb(null, {
            email: profile._json.email,
            picture: profile._json.picture,
          });
        } else {
          return cb(null, {
            id: fuser.id,
          });
        }
      } else {
        return cb(null, {
          id: cuser.id,
        });
      }
    }
  )
);

app.get(
  "/google",
  passport.authenticate("google", {
    scope: ["email"],
  })
);

app.get(
  "/google/callback",
  passport.authenticate("google", {
    failureRedirect: "/failure",
  }),
  function (req, res) {
    if (req.user.email) {
      res.redirect(
        `http://localhost:5173/register?oauth=1&email=${req.user.email}&picture=${req.user.picture}`
      );
    } else {
      const token = signToken(req.user.id);
      res.cookie("token", token);
      res.redirect("http://localhost:5173");
    }
  }
);

app.get("/failure", (req, res) => {
  console.log("OAUTH_FAILED");
  res.redirect("http://localhost:5173/register");
});

// -----------------------------------------------------------------------------------------------
// email verification route

app.get("/verify-email/:uniqueString", async (req, res) => {
  const { uniqueString } = req.params;

  const cuser = await client.findOne({ uniqueString: uniqueString });
  console.log(cuser);
  if (cuser) {
    cuser.isVerified = true;
    console.log("haha");
    await cuser.save();
  } else {
    const fuser = await freelancer.findOne({ uniqueString: uniqueString });
    fuser.isVerified = true;
    await fuser.save();
    if (fuser) {
    } else {
      console.log("User Not found");
      res.json("User Not Found");
    }
  }
});
