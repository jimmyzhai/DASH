#ifndef _SIRIUS_HEADERS_P4_
#define _SIRIUS_HEADERS_P4_

typedef bit<48>  EthernetAddress;
typedef bit<32>  IPv4Address;
typedef bit<128> IPv6Address;
typedef bit<128> IPv4ORv6Address;

enum bit<16> dash_direction_t {
    INVALID = 0,
    OUTBOUND = 1,
    INBOUND = 2
};

typedef bit<32> dash_flow_action_t;
typedef bit<32> dash_meter_class_t;

enum bit<8> dash_packet_source_t {
    EXTERNAL = 0,           // Packets from external sources.
    PIPELINE = 1,           // Packets from P4 pipeline.
    DPAPP = 2,              // Packets from data plane app.
    PEER = 3                // Packets from the paired DPU.
};

enum bit<4> dash_packet_type_t {
    REGULAR = 0,            // Regular packets from external sources.
    FLOW_SYNC_REQ = 1,      // Flow sync request packet.
    FLOW_SYNC_ACK = 2,      // Flow sync ack packet.
    DP_PROBE_REQ = 3,       // Data plane probe packet.
    DP_PROBE_ACK = 4        // Data plane probe ack packet.
};

// Packet operations for one kind of packet type
enum bit<4> dash_packet_op_t {
    NONE = 0,        // no op
    FLOW_CREATE = 1, // New flow creation.
    FLOW_UPDATE = 2, // Flow resimulation or any other reason causing existing flow to be updated.
    FLOW_DELETE = 3  // Flow deletion.
};

header ethernet_t {
    EthernetAddress dst_addr;
    EthernetAddress src_addr;
    bit<16>         ether_type;
}

const bit<16> ETHER_HDR_SIZE=112/8;

header ipv4_t {
    bit<4>      version;
    bit<4>      ihl;
    bit<8>      diffserv;
    bit<16>     total_len;
    bit<16>     identification;
    bit<3>      flags;
    bit<13>     frag_offset;
    bit<8>      ttl;
    bit<8>      protocol;
    bit<16>     hdr_checksum;
    IPv4Address src_addr;
    IPv4Address dst_addr;
}

const bit<16> IPV4_HDR_SIZE=160/8;

header ipv4options_t {
    varbit<320> options;
}

header udp_t {
    bit<16>  src_port;
    bit<16>  dst_port;
    bit<16>  length;
    bit<16>  checksum;
}

const bit<16> UDP_HDR_SIZE=64/8;

header vxlan_t {
    bit<8>  flags;
    bit<24> reserved;
    bit<24> vni;
    bit<8>  reserved_2;
}

const bit<16> VXLAN_HDR_SIZE=64/8;

header nvgre_t {
    bit<4>  flags;
    bit<9>  reserved;
    bit<3>  version;
    bit<16> protocol_type;
    bit<24> vsid;
    bit<8>  flow_id;
}

const bit<16> NVGRE_HDR_SIZE=64/8;

header tcp_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<32> seq_no;
    bit<32> ack_no;
    bit<4>  data_offset;
    bit<3>  res;
    bit<3>  ecn;
    bit<6>  flags;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgent_ptr;
}

const bit<16> TCP_HDR_SIZE=160/8;

header ipv6_t {
    bit<4>      version;
    bit<8>      traffic_class;
    bit<20>     flow_label;
    bit<16>     payload_length;
    bit<8>      next_header;
    bit<8>      hop_limit;
    IPv6Address src_addr;
    IPv6Address dst_addr;
}

const bit<16> IPV6_HDR_SIZE=320/8;


header flow_key_t {
    EthernetAddress eni_mac;
    bit<8> ip_proto;
    bit<16> vnet_id;
    IPv4ORv6Address src_ip;
    IPv4ORv6Address dst_ip;
    bit<16> src_port;
    bit<16> dst_port;
}

header flow_data_t {
    bit<32> version;
    dash_direction_t direction;
    dash_flow_action_t actions;
    dash_meter_class_t meter_class;
}

// dash packet metadata
header pktmeta_t {
    dash_packet_source_t packet_source;
    dash_packet_type_t packet_type;
    dash_packet_op_t packet_op;
    bit<16>     length;
}

struct headers_t {
    /* packet metadata headers */
    ethernet_t   dp_ethernet;
    pktmeta_t    pktmeta;
    flow_key_t   flow_key;
    flow_data_t  flow_data;

    /* Underlay 1 headers */
    ethernet_t    u1_ethernet;
    ipv4_t        u1_ipv4;
    ipv4options_t u1_ipv4options;
    ipv6_t        u1_ipv6;
    udp_t         u1_udp;
    tcp_t         u1_tcp;
    vxlan_t       u1_vxlan;
    nvgre_t       u1_nvgre;

    /* Underlay 0 headers */
    ethernet_t    u0_ethernet;
    ipv4_t        u0_ipv4;
    ipv4options_t u0_ipv4options;
    ipv6_t        u0_ipv6;
    udp_t         u0_udp;
    tcp_t         u0_tcp;
    vxlan_t       u0_vxlan;
    nvgre_t       u0_nvgre;

    /* Customer headers */
    ethernet_t    customer_ethernet;
    ipv4_t        customer_ipv4;
    ipv6_t        customer_ipv6;
    udp_t         customer_udp;
    tcp_t         customer_tcp;
}

enum bit<16> dash_encapsulation_t {
    INVALID = 0,
    VXLAN = 1,
    NVGRE = 2
}

#endif /* _SIRIUS_HEADERS_P4_ */
