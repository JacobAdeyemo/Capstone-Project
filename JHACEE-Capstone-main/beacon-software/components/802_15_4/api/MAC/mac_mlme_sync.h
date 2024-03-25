/**
 * Copyright (c) 2016 - 2021 Nordic Semiconductor ASA and Luxoft Global Operations Gmbh.
 *
 * All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form, except as embedded into a Nordic
 *    Semiconductor ASA integrated circuit in a product or a software update for
 *    such product, must reproduce the above copyright notice, this list of
 *    conditions and the following disclaimer in the documentation and/or other
 *    materials provided with the distribution.
 *
 * 3. Neither the name of Nordic Semiconductor ASA nor the names of its
 *    contributors may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * 4. This software, with or without modification, must only be used with a
 *    Nordic Semiconductor ASA integrated circuit.
 *
 * 5. Any software provided in binary form under this license must not be reverse
 *    engineered, decompiled, modified and/or disassembled.
 *
 * 
 * THIS SOFTWARE IS PROVIDED BY NORDIC SEMICONDUCTOR ASA "AS IS" AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY, NONINFRINGEMENT, AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL NORDIC SEMICONDUCTOR ASA OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */
#ifndef MAC_MLME_SYNC_H_INCLUDED
#define MAC_MLME_SYNC_H_INCLUDED

#if (CONFIG_SYNC_ENABLED == 1)

#include <stdint.h>
#include "mac_common.h"
#include "mac_task_scheduler.h"

/** @file
 * The MAC MLME Sync module declares the MAC Sync primitives and necessary types
 * according to the MAC specification.
 *
 * @defgroup mac_sync MAC MLME Sync API
 * @ingroup mac_15_4
 * @{
 * @brief Module to declare MAC MLME Sync API.
 * @details The MAC Sync module declares MLME Sync and sync loss primitives and necessary types according to
 * the MAC specification. More specifically, MLME Sync request aka mlme_sync_req(), and MLME
 * Sync Loss indication aka mlme_sync_loss_ind() primitives are declared.
 */

/**@brief Sync Loss reason enumeration. */
typedef enum
{
    MAC_SYNC_BEACON_LOST,                     /**< Beacon lost. */
    MAC_SYNC_REALIGNMENT,                     /**< Realignment. */
    MAC_SYNC_PAN_ID_CONFLICT                  /**< PAN ID Conflict. */
} mlme_sync_loss_reason_t;

/**
 * @brief   MLME-SYNC-LOSS.indication
 *
 * @details On receipt of the MLME-SYNC-LOSS.indication primitive, the next
 * higher layer is notified of a loss of synchronization.
 *
 * In accordance with IEEE Std 802.15.4-2006, section 7.1.15.2
 */
typedef struct
{
    mlme_sync_loss_reason_t loss_reason;      /**< Loss reason. */
    uint16_t                pan_id;           /**< PAN ID. */
    uint8_t                 logical_channel;  /**< Logical channel. */
#ifdef CONFIG_SUB_GHZ
    uint8_t                 channel_page;     /**< Channel page. */
#endif
#if (CONFIG_SECURE == 1)
    uint8_t                 security_level;   /**< Security level. */
    uint8_t                 key_id_mode;      /**< Key ID mode. */
    uint64_t                key_source;       /**< Key source. */
    uint8_t                 key_index;        /**< Key index. */
#endif
} mlme_sync_loss_ind_t;


#if (CONFIG_SYNC_REQ_ENABLED == 1)
/**
 * @brief   MLME-SYNC.request
 *
 * @details The MLME-SYNC.request primitive is generated by the next higher
 * layer of a device on a beacon-enabled PAN and issued to its MLME to
 * synchronize with the coordinator.
 *
 * In accordance with IEEE Std 802.15.4-2006, section 7.1.15.1
 */
typedef struct
{
    /** Do not edit this field. */
    mac_abstract_req_t  service;

    uint8_t             logical_channel;      /**< Logical channel. */
#ifdef CONFIG_SUB_GHZ
    uint8_t             channel_page;         /**< Channel page. */
#endif
    bool                track_beacon;         /**< Track beacon? */
} mlme_sync_req_t;

/**
 * @brief   MLME-SYNC-LOSS indication.
 *
 * @details Generated by the MLME of a device and issued to its next
 * higher layer in the event of a loss of synchronization with the
 * coordinator. It is also generated by the MLME of the PAN coordinator
 * and issued to its next higher layer in the event of a PAN ID conflict.
 *
 * @param[in] ind  MLME-SYNC-LOSS indication structure.
 *
 * In accordance with IEEE Std 802.15.4-2006, section 7.1.7.4
 */
extern void mlme_sync_loss_ind(mlme_sync_loss_ind_t * ind);


/**
 * @brief   MLME-SYNC request.
 *
 * @details Generated by the next higher layer of a device on a
 * beacon-enabled PAN and issued to its MLME to synchronize with
 * the coordinator.
 *
 * @param[in] req  MLME_SYNC request structure.
 *
 * In accordance with IEEE Std 802.15.4-2006, section 7.1.15.1
 */
void mlme_sync_req(mlme_sync_req_t * req);

#endif // (CONFIG_SYNC_REQ_ENABLED == 1)

/** @} */

#endif // (CONFIG_SYNC_ENABLED == 1)

#endif // MAC_MLME_SYNC_H_INCLUDED
