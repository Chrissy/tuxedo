const MailDev = require("maildev");
const Handlebars = require("handlebars");
const nodemailer = require("nodemailer");
const glob = require("glob");
const fs = require("fs");

const maildev = new MailDev();

const transporter = nodemailer.createTransport({
  host: "localhost",
  port: 1025,
  ignoreTLS: true,
});

const sendAllEmails = async () => {
  maildev.deleteAllEmail(() => {});

  glob("emails/*.html", function (er, files) {
    files.forEach(async file => {
      const data = fs.readFileSync(file.replace(".html", ".json"));
      const templateString = fs.readFileSync("./" + file).toString();
      const template = Handlebars.compile(templateString);
      const result = template(JSON.parse(data));

      const info = await transporter.sendMail({
        from: '"Fred Foo 👻" <foo@example.com>',
        to: "bar@example.com, baz@example.com",
        subject: "Hello ✔",
        text: "Hello world?",
        html: result,
      });
    })
  })
}

maildev.listen(() => {
  sendAllEmails();
});

glob("emails/*.html", function (er, files) {
  files.forEach(async file => {
    fs.watch("./" + file, () => {
      sendAllEmails();
    })
  })
})