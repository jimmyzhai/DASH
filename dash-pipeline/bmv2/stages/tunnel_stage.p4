#ifndef _DASH_STAGE_TUNNEL_P4_
#define _DASH_STAGE_TUNNEL_P4_

control tunnel_stage(
    inout headers_t hdr,
    inout metadata_t meta)
{
#ifdef TARGET_DPDK_PNA
    meta_encap_data_t tunnel_data;
#else
    encap_data_t tunnel_data;
#endif // TARGET_DPDK_PNA

    action set_tunnel_attrs(
        @SaiVal[type="sai_dash_encapsulation_t", default_value="SAI_DASH_ENCAPSULATION_VXLAN", create_only="true"]
        dash_encapsulation_t dash_encapsulation,

        @SaiVal[create_only="true"]
        bit<24> tunnel_key,

        @SaiVal[default_value="1", create_only="true"]
        bit<32> max_member_size,

        @SaiVal[type="sai_ip_address_t"]
        IPv4Address dip,

        @SaiVal[type="sai_ip_address_t"]
        IPv4Address sip)
    {
        meta.dash_tunnel_max_member_size = max_member_size;

        tunnel_data.dash_encapsulation = dash_encapsulation;
        tunnel_data.vni = tunnel_key;
        tunnel_data.underlay_sip = sip == 0 ? hdr.u0_ipv4.src_addr : sip;
        tunnel_data.underlay_dip = dip;
    }

    @SaiTable[name = "dash_tunnel", api = "dash_tunnel", order = 0, isobject="true"]
    table tunnel {
        key = {
            meta.dash_tunnel_id : exact @SaiVal[type="sai_object_id_t"];
        }

        actions = {
            set_tunnel_attrs;
        }
    }

    action select_tunnel_member(
        bit<16> dash_tunnel_member_id)
    {
        meta.dash_tunnel_member_id = dash_tunnel_member_id;
    }

    // This table is a helper table that used to select the tunnel member based on the index.
    // The entry of this table is created by DASH data plane app, when the tunnel member is created.
    @SaiTable[ignored = "true"]
    table tunnel_member_select {
        key = {
            meta.dash_tunnel_member_index : exact @SaiVal[type="sai_object_id_t", is_object_key="true"];
            meta.dash_tunnel_id : exact @SaiVal[type="sai_object_id_t"];
        }

        actions = {
            select_tunnel_member;
        }
    }

    action set_tunnel_member_attrs(
        @SaiVal[type="sai_object_id_t", mandatory="true", create_only="true"] bit<16> dash_tunnel_id,
        @SaiVal[type="sai_object_id_t", mandatory="true"] bit<16> dash_tunnel_next_hop_id)
    {
        // dash_tunnel_id in tunnel member must match the metadata
        REQUIRES(meta.dash_tunnel_id == dash_tunnel_id);

        meta.dash_tunnel_next_hop_id = dash_tunnel_next_hop_id;
    }

    @SaiTable[name = "dash_tunnel_member", api = "dash_tunnel", order = 1, isobject="true"]
    table tunnel_member {
        key = {
            meta.dash_tunnel_member_id : exact @SaiVal[type="sai_object_id_t", is_object_key="true"];
        }

        actions = {
            set_tunnel_member_attrs;
        }
    }

    action set_tunnel_next_hop_attrs(
        @SaiVal[type="sai_ip_address_t"]
        IPv4Address dip)
    {
        REQUIRES(dip != 0);
        tunnel_data.underlay_dip = dip;
    }

    @SaiTable[name = "dash_tunnel_next_hop", api = "dash_tunnel", order = 2, isobject="true"]
    table tunnel_next_hop {
        key = {
            meta.dash_tunnel_next_hop_id : exact @SaiVal[type="sai_object_id_t"];
        }

        actions = {
            set_tunnel_next_hop_attrs;
        }
    }

    apply {
        if (meta.dash_tunnel_id == 0) {
            return;
        }

        tunnel.apply();

        // If max member size is greater than 1, the tunnel is programmed with multiple members.
        if (meta.dash_tunnel_max_member_size > 1) {
#if defined(TARGET_BMV2_V1MODEL)
            // Select tunnel member based on the hash of the packet tuples.
            hash(meta.dash_tunnel_member_index, HashAlgorithm.crc32, (bit<32>)0, {
                meta.dst_ip_addr,
                meta.src_ip_addr,
                meta.src_l4_port,
                meta.dst_l4_port
            }, meta.dash_tunnel_max_member_size);
#else
            meta.dash_tunnel_member_index = 0;
#endif
            tunnel_member_select.apply();

            tunnel_member.apply();
            tunnel_next_hop.apply();
        }

        if (meta.routing_actions & dash_routing_actions_t.ENCAP_U0 == 0) {
            meta.tunnel_pointer = 0;
            push_action_encap_u0(hdr = hdr,
                                 meta = meta,
                                 encap = tunnel_data.dash_encapsulation,
                                 vni = tunnel_data.vni,
                                 underlay_sip = tunnel_data.underlay_sip,
                                 underlay_dip = tunnel_data.underlay_dip);
        }
        else {
            meta.tunnel_pointer = 1;
            push_action_encap_u1(hdr = hdr,
                                 meta = meta,
                                 encap = tunnel_data.dash_encapsulation,
                                 vni = tunnel_data.vni,
                                 underlay_sip = tunnel_data.underlay_sip,
                                 underlay_dip = tunnel_data.underlay_dip);
        }
    }
}

#endif /* _DASH_STAGE_TUNNEL_P4_ */
