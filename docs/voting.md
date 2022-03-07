<!--
   - SPDX-FileCopyrightText: 2022 TQ Tezos <https://tqtezos.com/>
   -
   - SPDX-License-Identifier: LicenseRef-MIT-TQ
   -->

# Voting with `tezos-packaging` on Ubuntu

`tezos-packaging` provides an easy way to propose amendments and cast votes on the Tezos blockchain.

This article documents the way to vote on Ubuntu, as well as any prerequisite steps necessary.

## Using the wizard

You can easily use Tezos Voting Wizard to vote on mainnet.

A prerequisite for this is a mainnet baking instance already set up and running. An easy way to configure
it is Tezos Setup Wizard. See the [baking](./baking.md#prerequisites) article for more details.

After all the services required for baking have been set up, run:

```bash
tezos-voting-wizard
```

The wizard displays the voting period and offers approppriate possible actions for that period.

# Advanced usage

## Using custom networks

`tezos-voting-wizard` supports voting on custom networks, in turn enabled by `tezos-packaging`'s
support for custom chain systemd services. The process to set up a custom baking instance is
documented [here](./baking.md#using-a-custom-chain).

After the custom baking instance is fully set up, you can vote or propose amendments on it by running:

```bash
tezos-voting-wizard
```