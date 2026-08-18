import makeValidation from "@withvoid/make-validation";
import UserModel, { USER_TYPES } from "../mongoDB/models/user.js";

export default {
  onGetAllUsers: async (req, res) => {
    try {
      const users = await UserModel.find();
      return res.status(200).json({ success: true, users });
    } catch (err) {
      return res.status(500).json({ success: false, error: err });
    }
  },
  onGetUserById: async (req, res) => {
    try {
      const user = await UserModel.findOne({ _id: req.params.id });
      if (!user) throw "No user with this id found";
      return res.status(200).json({ success: true, user });
    } catch (err) {
      return res.status(500).json({ success: false, error: err });
    }
  },
  onCreateUser: async (req, res) => {
    try {
      console.log(req.body); 
      const validation = makeValidation((types) => ({
        payload: req.body,
        checks: {
          id : {type : types.string },
          username : {type : types.string},
          type: { type: types.enum, options: { enum: USER_TYPES } },
        },
      }));
      if (!validation.success) return res.status(400).json(validation);
      const { id, type } = req.body;
      const check = await UserModel.findOne({ _id: id});
      if (check) throw "User exists already";
      const pfp = req.body.pfp || ""
      const user = await UserModel.create({_id : id, type,username : req.body.username,pfp});
      return res.status(200).json({ success: true, user });
    } catch (err) {
      return res.status(500).json({ success: false, error: err });
    }
  },
  onDeleteUserById: async (req, res) => {
    try {
      const result = await UserModel.deleteOne({_id : req.params.id});
      return res.status(200).json({
        success:true, message : "Deleted " + result.deletedCount + " users"
      }) 
    }catch (err) {
        return res.status(500).json({success:false,error : err})
    }
  },
  onSetUserToken: async (req, res) => {
    try {
      const validation = makeValidation((types) => ({
        payload: req.body,
        checks: {
          id: { type: types.string },
          FCMToken: { type: types.string },
        },
      }));
      if (!validation.success) return res.status(400).json(validation);
      const { id, FCMToken } = req.body;
      const user = await UserModel.findOneAndUpdate(
        { _id: id },
        { FCMToken },
        { new: true }
      );
      if (!user) throw "User not found";
      return res.status(200).json({ success: true, user });
    } catch (err) {
      return res.status(500).json({ success: false, error: err });
    }
  },
};
