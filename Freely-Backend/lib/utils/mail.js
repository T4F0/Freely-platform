//importing modules
import nodemailer from "nodemailer";

export const sendingMail = async ({ from, to, subject, text }) => {
  try {
    let mailOptions = {
      from,
      to,
      subject,
      text,
    };
    const Transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.email,
        pass: process.env.emailpassword,
      },
    });

    return await Transporter.sendMail(mailOptions);
  } catch (error) {
    console.log(error);
  }
};
