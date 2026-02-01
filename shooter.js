#!/usr/bin/env node

import { Command } from "commander";
import { ethers } from "ethers";
import chalk from "chalk";
import config from "./shooter.config.js";

const program = new Command();

const ABI = [
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "function balanceOf(address) view returns (uint256)",
  "function mutationPhase() view returns (string)",
  "function believerStatus(address) view returns (bool,uint256)"
];

const provider = new ethers.JsonRpcProvider(config.rpc);
const contract = new ethers.Contract(config.contract, ABI, provider);

program
  .name("shooter")
  .description("Shooter CLI — it launched anyway.")
  .version("0.1.0");

program
  .command("status")
  .description("Check Shooter mutation phase")
  .action(async () => {
    const phase = await contract.mutationPhase();
    console.log(chalk.magenta.bold("\nSHOOTER STATUS"));
    console.log(chalk.gray("Mutation Phase:"), chalk.whiteBright(phase));
  });

program
  .command("believer")
  .argument("<address>", "wallet address")
  .description("Check early believer memory")
  .action(async (address) => {
    const [early, block] = await contract.believerStatus(address);

    console.log(chalk.cyan.bold("\nBELIEVER SCAN"));
    console.log("Address:", chalk.white(address));
    console.log("Early Believer:", early ? chalk.green("YES") : chalk.red("NO"));
    console.log("First Seen Block:", block.toString());
  });

program
  .command("balance")
  .argument("<address>", "wallet address")
  .description("Check SHOOTER balance")
  .action(async (address) => {
    const bal = await contract.balanceOf(address);
    console.log(chalk.yellow.bold("\nBALANCE"));
    console.log(
      chalk.white(
        ethers.formatUnits(bal, 18),
        "SHOOT"
      )
    );
  });

program.parse();
