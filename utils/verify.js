const { run } = require("hardhat")

const verify = async (contractAddress, args) => {
    console.log("verify contract")
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("already verified!")
        } else {
            console.log(e)
        }
    }
}

module.exports = { verify }
