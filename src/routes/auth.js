const express = require("express");
const router = express.Router();
const userSchema = require("../database/schemas/User");
var FileReader = require("filereader");
const fs = require("fs");

router.post("/:item", async (req, res) => {
  const key = req.body.key;
  const id = req.body.id;

  // check if the key exists
  const user = await userSchema.findOne({ robloxId: id });
  if (!user) {
    console.log("User does not exist.");
    return res.status(401).send("User does not exist.");
  }

  // check if the key is valid
  // if (!user.Keys.includes(key)) {
  //     console.log("Invalid key.");
  //     return res.status(401).send("Invalid key.");
  // }

  // check if the user has the liscence
  if (!user.Liscences.includes(req.params.item)) {
    console.log(user.Liscences);

    console.log("User does not have the liscence.");
    return res.status(401).send("User does not have the liscence.");
  }

  if (req.body.key && req.body.id) {
    // return a json sayuing that the user is authenticated
    console.log("User authenticated.");

    if (req.body.file) {
      const file = req.body.file;
      // if file is Plane/teat.lua return as a string the content of the file ../scripts/Plane/test.lua
      // let fileReader = new FileReader();

      // fileReader.onload = function (e) {
      //     let text = fileReader.result;
      //     console.log(text);
      // }

      // await fileReader.readAsText(__dirname+"/scripts/"+file);
      fs.readFile(__dirname + "/scripts/" + file, "utf8", (err, data) => {
        console.log(data);
        return res.status(200).json({ authenticated: true, src: data });
      });
    } else {
      await res
        .status(200)
        .json({ authenticated: true, src: `print("worked lol")` });
    }
  } else {
    await res.status(401).send("Invalid request");
  }
});

module.exports = router;
