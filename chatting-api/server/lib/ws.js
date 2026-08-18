import UserModel from "../mongoDB/models/user.js";

class WebSockets {
  users = [];
  connection(client) {
    client.on("disconnect", async () => {
      console.log("disconnect");
      this.users = this.users.filter(async (user) => {
        if (user.socketId === client.id) {
          await UserModel.setUserOffline(user.userId);
          return false;
        }
        return true;
      });
    });
    client.on("init", async (userId) => {
      console.log("init", userId);
      this.users.push({
        socketId: client.id,
        userId: userId,
      });
      await UserModel.setUserOnline(userId);
    });
    client.on("subscribe", (data) => {
      console.log("subscribe",data);
      this.subscribeOtherUser(data.room, data?.otherUserId || "");
      client.join(data.room);
    });
    client.on("unsubscribe", (room) => {
      client.leave(room);
    });
    client.on("typing", (data) => {
      console.log("typing", data,client.rooms);
      client.to(data.room).emit("typing", data);
    });
    client.on("stop typing", (data) => {
      console.log("stop typing", data);
      client.to(data.room).emit("stop typing", data);
    });
  }

  subscribeOtherUser(room, otherUserId) {
    const userSockets = this.users.filter(
      (user) => user.userId === otherUserId
    );
    userSockets.map((userInfo) => {
      console.log(userInfo);
      const socketConn = global.io.sockets.sockets.get(userInfo.socketId);
      if (socketConn) {
        socketConn.join(room);
      }
    });
  }
}

export default new WebSockets();
