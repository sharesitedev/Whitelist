const express = require("express");
const path = require("path");
const bodyParser = require("body-parser");

require("dotenv").config();

const app = express();

let PORT = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname, "public")));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.set("view engine", "pug");
app.set("views", "./src/views");

require("./database");

const initRoutes = require("./routes/init");
const authRoutes = require("./routes/auth");

const UserSchema = require("./database/schemas/User");
// UserSchema.create({
//     robloxId: 266775769,
//     Liscences: ["Cool Liscence"],
//     Keys: ["3679sdf03"]
// });

app.use('/', initRoutes);
app.use('/auth', authRoutes);

app.listen(PORT, () => console.log(`Server started on port ${PORT}`));