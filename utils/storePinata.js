const pinataSDK = require("@pinata/sdk")
const pinata = pinataSDK(process.env.PINATA_API_KEY, process.env.PINATA_API_SECRET)
const fs = require("fs")
const path = require("path")

async function storeImages(imagesLocation) {
    const imagesFullPath = path.resolve(imagesLocation)
    const fileNames = fs.readdirSync(imagesFullPath)

    const responses = []
    const nftNames = []
    for (fileIndex in fileNames) {
        const readableStream = fs.createReadStream(`${imagesFullPath}/${fileNames[fileIndex]}`)
        try {
            const response = await pinata.pinFileToIPFS(readableStream)
            responses.push(response)
            nftNames.push(fileNames[fileIndex].replace(".png", ""))
        } catch (e) {
            console.log(e)
        }
    }

    return { responses, nftNames }
}

async function storeTokenUriMetadata(metadata) {
    try {
        const response = await pinata.pinJSONToIPFS(metadata)
        return response
    } catch (e) {
        console.log(e)
    }
    return null
}

module.exports = {
    storeImages,
    storeTokenUriMetadata,
}
