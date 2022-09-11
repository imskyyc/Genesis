-- (c) 2022 imskyyc
-- This code is a part of the Genesis framework (https://github.com/imskyyc/Genesis) licensed under the MIT license (see LICENSE.lua for details)

export type Array<T> = { T }
export type Dictionary<T, K> = { [T]: K }
export type HookedFunction = {
    __initializer: string,
    __connected: true,
    __yield: boolean?,

    Function: (Player: Player, Payload: any) -> any?,
    UnHook: () -> nil
}

-- return
return nil