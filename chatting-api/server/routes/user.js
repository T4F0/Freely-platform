import express from "express";


import user from "../controllers/user.js"

const router = express.Router();

router.get("/",user.onGetAllUsers)
        .post("/",user.onCreateUser)
        .get("/:id",user.onGetUserById)
        .delete("/:id",user.onDeleteUserById)
        .put("/token",user.onSetUserToken)

export default router;