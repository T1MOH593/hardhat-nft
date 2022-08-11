const { assert, expect } = require("chai")
const { deployments, getNamedAccounts, ethers, network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("BasicNft", function () {
          let basicNft, deployer

          beforeEach(async () => {
              deployer = (await getNamedAccounts()).deployer
              await deployments.fixture(["basicNft"])
              basicNft = await ethers.getContract("BasicNft", deployer)
          })

          describe("constructor", function () {
              it("Should set name, symbol and counter", async () => {
                  const name = await basicNft.name()
                  const symbol = await basicNft.symbol()
                  const counter = await basicNft.getCounter()

                  assert.equal(name, "Dogie")
                  assert.equal(symbol, "DOG")
                  assert.equal(counter.toString(), "0")
              })
          })
          describe("mint", function () {
              it("Should update counter", async () => {
                  await basicNft.mint()
                  const counter = await basicNft.getCounter()

                  assert.equal(counter.toString(), "1")
              })
          })
      })
