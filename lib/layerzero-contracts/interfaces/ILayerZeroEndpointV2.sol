// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @dev Minimal LayerZero Endpoint V2 interface for lzRead functionality
 * Based on LayerZero documentation: https://docs.layerzero.network/v2/
 */
interface ILayerZeroEndpointV2 {
    /**
     * @dev Read a payload from a remote chain via LayerZero
     * @param _srcEid Source endpoint ID (chain ID)
     * @param _caller Address of the caller on the remote chain
     * @param _oappOptions OApp options
     * @param _payload Encoded payload
     * @return result Result of the remote call
     */
    function lzReceive(uint32 _srcEid, address _caller, bytes calldata _oappOptions, bytes calldata _payload)
        external
        returns (bytes memory result);

    /**
     * @dev Query a remote chain for data (pull method)
     * @param _dstEid Destination endpoint ID
     * @param _target Address of the target contract on remote chain
     * @param _payload Encoded function call data
     * @return result Result of the remote call
     */
    function lzRead(uint32 _dstEid, address _target, bytes calldata _payload)
        external
        view
        returns (bytes memory result);
}
