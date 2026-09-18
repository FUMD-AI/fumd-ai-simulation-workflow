// =============================================================================
// NRSeveralBSALC.ned — NR 5G Urban Network Topology Definition
// Scenario: Alicante city centre, 9 gNodeBs, downlink VoIP, SUMO mobility
//
// Part of: FUMD-AI / fumd-ai-simulation-workflow
// Repository: https://github.com/FUMD-AI/fumd-ai-simulation-workflow
// Related: https://github.com/FUMD-AI/fumd-ai-preprocessing-workflow
//
// Authors:
//   Cristina Bernad, Miguel Hernandez University (ORCID: 0000-0001-9537-415X)
//   Sonja Filiposka, Ss. Cyril and Methodius University (ORCID: 0000-0003-0034-2855)
//   Katya Gilly, Miguel Hernandez University (ORCID: 0000-0002-8985-0639)
//
// Acknowledgement: FUMD-AI project, EOSC GRAVITY Grant 25-EOSC-GRV-INTER-013
// https://eosc.eu/horizon-europe-projects/fumd-ai
//
// SPDX-License-Identifier: MIT
// =============================================================================

package simu5g.simulations.nr.UrbanALCsimu5G;

// --- INET imports ---
// IPv4 configurator: assigns static IP addresses and routes from demo.xml
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
// Records routing table changes to the event log for post-simulation analysis
import inet.networklayer.ipv4.RoutingTableRecorder;
// Standard IP host: used for the content server (server1)
import inet.node.inet.StandardHost;
// IP router: connects server1 to the 5G core network
import inet.node.inet.Router;
// 10 Gbps Ethernet channel: backbone link type for all wired connections
import inet.node.ethernet.Eth10G;

// --- Simu5G imports ---
// LTE/NR channel control: manages the radio channel and interference model
import simu5g.world.radio.LteChannelControl;
// Carrier aggregation support (used even in single-carrier NR deployments)
import simu5g.common.carrierAggregation.CarrierAggregation;
// User Plane Function: 5G core gateway between data network and radio access
import simu5g.nodes.Upf;
// Binder: global registry mapping MAC node IDs to module references
import simu5g.common.binder.Binder;
// gNodeB: 5G NR base station
import simu5g.nodes.gNodeB;
// NrCar: NR-capable vehicle UE (instantiated dynamically by VeinsInetManager)
import simu5g.nodes.NrCar;

// --- Veins import ---
// VeinsInetManager: bridges OMNeT++ and SUMO via TraCI; dynamically creates
// and destroys NrCar modules as vehicles enter and leave the SUMO scenario
import org.car2x.veins.subprojects.veins_inet.VeinsInetManager;


// =============================================================================
// Network: NRSeveralBSALC
//
// Topology: 9 NR gNodeBs deployed at real Alicante city-centre locations,
// connected in a full X2 mesh (36 bidirectional links). Vehicles enter and
// leave the simulation area driven by SUMO mobility traces. A single server
// on the data network sends VoIP streams to all active vehicles.
//
// Coordinate system: OMNeT++ canvas coordinates (pixels), derived from the
// SUMO road network bounding box. Playground dimensions are set in omnetpp.ini.
// =============================================================================
network NRSeveralBSALC
{
    parameters:
        // Playground bounding box — must match the SUMO road network extent.
        // Values are set in omnetpp.ini (playgroundSizeX/Y/Z).
        double playgroundSizeX @unit(m);
        double playgroundSizeY @unit(m);
        double playgroundSizeZ @unit(m);

        @display("bgb=5000,5000");

        // numBgCells: number of background interfering cells (not used in this
        // scenario; interference is modelled via the channel model instead).
        int numBgCells = default(0);

    submodules:

        // =====================================================================
        // Infrastructure and simulation support modules
        // =====================================================================

        // Records IPv4 routing table changes throughout the simulation.
        // Useful for post-simulation debugging; disabled in omnetpp.ini for
        // production runs to reduce overhead.
        routingRecorder: RoutingTableRecorder {
            @display("p=4273.416,160.128;is=s");
        }

        // Assigns static IP addresses and routes to all nodes from demo.xml.
        // Must be present even when using dynamic cell association, because
        // the UPF and gNodeBs require IP connectivity to the data network.
        configurator: Ipv4NetworkConfigurator {
            @display("p=4403.52,1190.952");
        }

        // Connects OMNeT++ to the SUMO traffic simulator via the TraCI protocol.
        // Creates and destroys NrCar modules as vehicles enter/leave the scenario.
        // Parameters (host, port, updateInterval, etc.) are set in omnetpp.ini.
        veinsManager: VeinsInetManager {
            @display("p=3382.704,230.184;is=s");
        }

        // Manages the shared radio channel; required by all PHY modules.
        // Controls which nodes can potentially receive each other's signals.
        channelControl: LteChannelControl {
            @display("p=3372.696,750.6;is=s");
        }

        // Global registry: maps MAC node IDs to module references.
        // Used by PDCP, RLC, and MAC layers for cross-module lookups.
        // Patched to support >1024 NR UEs (see fumd-ai-simulation-workflow).
        binder: Binder {
            @display("p=4473.576,710.568;is=s");
        }

        // Required by Simu5G even in single-carrier NR deployments.
        carrierAggregation: CarrierAggregation {
            @display("p=50.993748,258.7;is=s");
        }

        // =====================================================================
        // Data network
        // =====================================================================

        // Content server: runs one VoipSender application per vehicle,
        // sending 40-byte UDP packets (G.729 equivalent) to each car's IP.
        // Number of active apps equals numApps, set per [Config] in omnetpp.ini.
        server1: StandardHost {
            @display("p=4273.416,3442.752;is=n;i=device/server");
        }

        // IP router connecting server1 to the 5G core (UPF).
        router: Router {
            @display("p=1781.424,4443.552;i=device/smallrouter");
        }

        // 5G User Plane Function: gateway between data network and RAN.
        // Routes downlink IP traffic from server1/router to the correct gNodeB
        // based on the UE's current serving cell.
        upf: Upf {
            @display("p=630.504,4453.56;is=l");
        }

        // =====================================================================
        // Radio Access Network — 9 NR gNodeBs at Alicante city-centre locations
        //
        // Display coordinates are derived from the SUMO road network
        // (Alicante OpenStreetMap export), scaled to the OMNeT++ canvas.
        // Each gNodeB is assigned macCellId and macNodeId 1..9 in omnetpp.ini.
        // =====================================================================

        gNodeB1: gNodeB {
            @display("p=436.092238969096,791.621380800279;is=vl");  // Luceros
        }
        gNodeB2: gNodeB {
            @display("p=859.355020899393,1059.86284739993;is=vl");  // Gabriel Miró
        }
        gNodeB3: gNodeB {
            @display("p=31.5510147169178,1120.28048100001;is=vl");  // Teatro Arniches
        }
        gNodeB4: gNodeB {
            @display("p=746.203731640691,457.422523200876;is=vl");  // Plaza del Mercado
        }
        gNodeB5: gNodeB {
            @display("p=594.91447310333,1510.80100022004;is=vl");   // Paseo Canalejas
        }
        gNodeB6: gNodeB {
            @display("p=1165.47101041388,522.572724000383;is=vl");  // Parque de La Ereta
        }
        gNodeB7: gNodeB {
            @display("p=1420.08777723181,569.832051600315;is=vl");  // Castillo Santa Bárbara
        }
        gNodeB8: gNodeB {
            @display("p=1460.04807360543,1039.8489534;is=vl");      // Playa Postiguet
        }
        gNodeB9: gNodeB {
            @display("p=1304.36343422133,1504.39244219979;is=vl");  // Zona Volvo
        }

        // =====================================================================
        // Vehicle UEs — dynamically managed by VeinsInetManager
        //
        // car[0] is declared as a size-0 placeholder so that omnetpp.ini
        // parameters matching car[*] are accepted at startup. VeinsInetManager
        // dynamically creates and destroys car[i] instances as vehicles enter
        // and leave the SUMO scenario during the simulation.
        // =====================================================================
        car[0]: NrCar {
            @display("is=vs");
        }

    connections allowunconnected:

        // =====================================================================
        // Data network connections
        // All links use 10 Gbps Ethernet (Eth10G); capacity is not a bottleneck.
        // =====================================================================
        server1.pppg++ <--> Eth10G <--> router.pppg++;
        router.pppg++  <--> Eth10G <--> upf.filterGate;

        // =====================================================================
        // 5G Core — UPF to gNodeB N2/N3 interface connections
        // Each gNodeB has a dedicated Eth10G link to the UPF.
        // =====================================================================
        upf.pppg++ <--> Eth10G <--> gNodeB1.ppp;
        upf.pppg++ <--> Eth10G <--> gNodeB2.ppp;
        upf.pppg++ <--> Eth10G <--> gNodeB3.ppp;
        upf.pppg++ <--> Eth10G <--> gNodeB4.ppp;
        upf.pppg++ <--> Eth10G <--> gNodeB5.ppp;
        upf.pppg++ <--> Eth10G <--> gNodeB6.ppp;
        upf.pppg++ <--> Eth10G <--> gNodeB7.ppp;
        upf.pppg++ <--> Eth10G <--> gNodeB8.ppp;
        upf.pppg++ <--> Eth10G <--> gNodeB9.ppp;

        // =====================================================================
        // X2 interface connections — full mesh between all 9 gNodeBs
        //
        // 36 bidirectional X2 links; each gNodeB has 8 x2++ gates (peers).
        // The x2++ auto-increment gate assignment determines the x2pppN index
        // on each side, which must match the connectAddress in omnetpp.ini.
        //
        // Comment format: BSi j | BSk m means:
        //   gNodeBi.x2[j] <-> gNodeBk.x2[m]
        //   (i.e. gNodeBi.x2App[j] uses x2pppj; gNodeBk.x2App[m] uses x2pppm)
        // =====================================================================

        // gNodeB1 to all peers (x2[0..7] on gNodeB1)
        gNodeB1.x2++ <--> Eth10G <--> gNodeB2.x2++; // BS1[0] | BS2[0]
        gNodeB1.x2++ <--> Eth10G <--> gNodeB3.x2++; // BS1[1] | BS3[0]
        gNodeB1.x2++ <--> Eth10G <--> gNodeB4.x2++; // BS1[2] | BS4[0]
        gNodeB1.x2++ <--> Eth10G <--> gNodeB5.x2++; // BS1[3] | BS5[0]
        gNodeB1.x2++ <--> Eth10G <--> gNodeB6.x2++; // BS1[4] | BS6[0]
        gNodeB1.x2++ <--> Eth10G <--> gNodeB7.x2++; // BS1[5] | BS7[0]
        gNodeB1.x2++ <--> Eth10G <--> gNodeB8.x2++; // BS1[6] | BS8[0]
        gNodeB1.x2++ <--> Eth10G <--> gNodeB9.x2++; // BS1[7] | BS9[0]

        // gNodeB2 to remaining peers (x2[1..7] on gNodeB2)
        gNodeB2.x2++ <--> Eth10G <--> gNodeB3.x2++; // BS2[1] | BS3[1]
        gNodeB2.x2++ <--> Eth10G <--> gNodeB4.x2++; // BS2[2] | BS4[1]
        gNodeB2.x2++ <--> Eth10G <--> gNodeB5.x2++; // BS2[3] | BS5[1]
        gNodeB2.x2++ <--> Eth10G <--> gNodeB6.x2++; // BS2[4] | BS6[1]
        gNodeB2.x2++ <--> Eth10G <--> gNodeB7.x2++; // BS2[5] | BS7[1]
        gNodeB2.x2++ <--> Eth10G <--> gNodeB8.x2++; // BS2[6] | BS8[1]
        gNodeB2.x2++ <--> Eth10G <--> gNodeB9.x2++; // BS2[7] | BS9[1]

        // gNodeB3 to remaining peers (x2[2..7] on gNodeB3)
        gNodeB3.x2++ <--> Eth10G <--> gNodeB4.x2++; // BS3[2] | BS4[2]
        gNodeB3.x2++ <--> Eth10G <--> gNodeB5.x2++; // BS3[3] | BS5[2]
        gNodeB3.x2++ <--> Eth10G <--> gNodeB6.x2++; // BS3[4] | BS6[2]
        gNodeB3.x2++ <--> Eth10G <--> gNodeB7.x2++; // BS3[5] | BS7[2]
        gNodeB3.x2++ <--> Eth10G <--> gNodeB8.x2++; // BS3[6] | BS8[2]
        gNodeB3.x2++ <--> Eth10G <--> gNodeB9.x2++; // BS3[7] | BS9[2]

        // gNodeB4 to remaining peers (x2[3..7] on gNodeB4)
        gNodeB4.x2++ <--> Eth10G <--> gNodeB5.x2++; // BS4[3] | BS5[3]
        gNodeB4.x2++ <--> Eth10G <--> gNodeB6.x2++; // BS4[4] | BS6[3]
        gNodeB4.x2++ <--> Eth10G <--> gNodeB7.x2++; // BS4[5] | BS7[3]
        gNodeB4.x2++ <--> Eth10G <--> gNodeB8.x2++; // BS4[6] | BS8[3]
        gNodeB4.x2++ <--> Eth10G <--> gNodeB9.x2++; // BS4[7] | BS9[3]

        // gNodeB5 to remaining peers (x2[4..7] on gNodeB5)
        gNodeB5.x2++ <--> Eth10G <--> gNodeB6.x2++; // BS5[4] | BS6[4]
        gNodeB5.x2++ <--> Eth10G <--> gNodeB7.x2++; // BS5[5] | BS7[4]
        gNodeB5.x2++ <--> Eth10G <--> gNodeB8.x2++; // BS5[6] | BS8[4]
        gNodeB5.x2++ <--> Eth10G <--> gNodeB9.x2++; // BS5[7] | BS9[4]

        // gNodeB6 to remaining peers (x2[5..7] on gNodeB6)
        gNodeB6.x2++ <--> Eth10G <--> gNodeB7.x2++; // BS6[5] | BS7[5]
        gNodeB6.x2++ <--> Eth10G <--> gNodeB8.x2++; // BS6[6] | BS8[5]
        gNodeB6.x2++ <--> Eth10G <--> gNodeB9.x2++; // BS6[7] | BS9[5]

        // gNodeB7 to remaining peers (x2[6..7] on gNodeB7)
        gNodeB7.x2++ <--> Eth10G <--> gNodeB8.x2++; // BS7[6] | BS8[6]
        gNodeB7.x2++ <--> Eth10G <--> gNodeB9.x2++; // BS7[7] | BS9[6]

        // Final link: gNodeB8 <-> gNodeB9 (x2[7] on both)
        gNodeB8.x2++ <--> Eth10G <--> gNodeB9.x2++; // BS8[7] | BS9[7]
}
