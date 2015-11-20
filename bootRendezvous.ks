// bootRendezvous.ks - Prepare for rendezvous to target.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

print "Initializing rendezvous CPU.".
for file in list("rendezvous", "lib_navball", "manoeuvre", "mechanics", "navball") {
  copy file from archive.
}
