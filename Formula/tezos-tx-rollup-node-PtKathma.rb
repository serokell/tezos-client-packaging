#!/usr/bin/env ruby

# SPDX-FileCopyrightText: 2022 Oxhead Alpha
# SPDX-License-Identifier: LicenseRef-MIT-OA

class TezosTxRollupNodePtkathma < Formula
  @all_bins = []

  class << self
    attr_accessor :all_bins
  end
  homepage "https://gitlab.com/tezos/tezos"

  url "https://gitlab.com/tezos/tezos.git", :tag => "v15.0-rc1", :shallow => false

  version "v15.0-rc1-1"

  build_dependencies = %w[pkg-config coreutils autoconf rsync wget rustup-init]
  build_dependencies.each do |dependency|
    depends_on dependency => :build
  end

  dependencies = %w[gmp hidapi libev libffi tezos-sapling-params]
  dependencies.each do |dependency|
    depends_on dependency
  end
  desc "Tezos transaction rollup node for PtKathma"

  bottle do
    root_url "https://github.com/serokell/tezos-packaging/releases/download/#{TezosTxRollupNodePtkathma.version}/"
    sha256 cellar: :any, monterey: "e22731b5b22a1c917fdbfc24ff55ac99e0be76bd7695f23f171350420239017c"
    sha256 cellar: :any, big_sur: "61ef8db4093e333e8fb8bed52886af483d5ef71090402a7d1a588caea8b2d0e5"
    sha256 cellar: :any, arm64_big_sur: "07ccfa7344f33b3a7200735a9e1b4ad3934dbe04f1bdb587175989e69727308d"
  end

  def make_deps
    ENV.deparallelize
    ENV["CARGO_HOME"]="./.cargo"
    # Disable usage of instructions from the ADX extension to avoid incompatibility
    # with old CPUs, see https://gitlab.com/dannywillems/ocaml-bls12-381/-/merge_requests/135/
    ENV["BLST_PORTABLE"]="yes"
    # Here is the workaround to use opam 2.0.9 because Tezos is currently not compatible with opam 2.1.0 and newer
    arch = RUBY_PLATFORM.include?("arm64") ? "arm64" : "x86_64"
    system "curl", "-L", "https://github.com/ocaml/opam/releases/download/2.0.9/opam-2.0.9-#{arch}-macos", "--create-dirs", "-o", "#{ENV["HOME"]}/.opam-bin/opam"
    system "chmod", "+x", "#{ENV["HOME"]}/.opam-bin/opam"
    ENV["PATH"]="#{ENV["HOME"]}/.opam-bin:#{ENV["PATH"]}"
    system "rustup-init", "--default-toolchain", "1.60.0", "-y"
    system "opam", "init", "--bare", "--debug", "--auto-setup", "--disable-sandboxing"
    system ["source .cargo/env",  "make build-deps"].join(" && ")
  end

  def install_template(dune_path, exec_path, name)
    bin.mkpath
    self.class.all_bins << name
    system ["eval $(opam env)", "dune build #{dune_path}", "cp #{exec_path} #{name}"].join(" && ")
    bin.install name
    ln_sf "#{bin}/#{name}", "#{bin}/#{name.gsub("octez", "tezos")}"
  end

  def install
    startup_contents =
      <<~EOS
      #!/usr/bin/env bash

      set -euo pipefail

      node="#{bin}/octez-tx-rollup-node-PtKathma"

      "$node" init "$ROLLUP_MODE" config \
          for "$ROLLUP_ALIAS" \
          --rpc-addr "$ROLLUP_NODE_RPC_ENDPOINT" \
          --force

      "$node" --endpoint "$NODE_RPC_SCHEME://$NODE_RPC_ADDR" \
          run "$ROLLUP_MODE" for "$ROLLUP_ALIAS"
      EOS
    File.write("tezos-tx-rollup-node-PtKathma-start", startup_contents)
    bin.install "tezos-tx-rollup-node-PtKathma-start"
    make_deps
    install_template "src/proto_014_PtKathma/bin_tx_rollup_node/main_tx_rollup_node_014_PtKathma.exe",
                     "_build/default/src/proto_014_PtKathma/bin_tx_rollup_node/main_tx_rollup_node_014_PtKathma.exe",
                     "octez-tx-rollup-node-PtKathma"
  end
  plist_options manual: "tezos-tx-rollup-node-PtKathma run for"
  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
      "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>Program</key>
          <string>#{opt_bin}/tezos-tx-rollup-node-PtKathma-start</string>
          <key>EnvironmentVariables</key>
            <dict>
              <key>TEZOS_CLIENT_DIR</key>
              <string>#{var}/lib/tezos/client</string>
              <key>NODE_RPC_SCHEME</key>
              <string>http</string>
              <key>NODE_RPC_ADDR</key>
              <string>localhost:8732</string>
              <key>ROLLUP_NODE_RPC_ENDPOINT</key>
              <string>127.0.0.1:8472</string>
              <key>ROLLUP_MODE</key>
              <string>observer</string>
              <key>ROLLUP_ALIAS</key>
              <string>rollup</string>
          </dict>
          <key>RunAtLoad</key><true/>
          <key>StandardOutPath</key>
          <string>#{var}/log/#{name}.log</string>
          <key>StandardErrorPath</key>
          <string>#{var}/log/#{name}.log</string>
        </dict>
      </plist>
    EOS
  end
  def post_install
    mkdir "#{var}/lib/tezos/client"
  end
end