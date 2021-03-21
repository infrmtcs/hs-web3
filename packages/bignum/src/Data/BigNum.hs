{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings          #-}

-- |
-- Module      :  Data.BigNum
-- Copyright   :  Aleksandr Krupenkin 2016-2021
-- License     :  Apache-2.0
--
-- Maintainer  :  mail@akru.me
-- Stability   :  experimental
-- Portability :  unportable
--
-- Big numbers and codecs for Haskell Web3 library.
--

module Data.BigNum (Word256, Word128, H256, h256, H512, h512) where

import           Basement.Block                   (Block)
import           Basement.Types.Word128           (Word128 (..))
import           Basement.Types.Word256           (Word256 (..))
import           Codec.Scale                      ()
import           Codec.Scale.Class                (Decode (..), Encode (..))
import           Data.ByteArray                   (ByteArrayAccess, convert)
import qualified Data.ByteArray                   as A (length)
import           Data.ByteArray.HexString.Convert (FromHex (..), ToHex (..),
                                                   fromBytes)
import           Data.Maybe                       (fromJust)
import           Data.Serialize.Get               (getByteString)
import           Data.Serialize.Put               (putByteString)
import           Data.String                      (IsString (..))
import           Data.Word                        (Word8)

instance Encode Word128 where
    put (Word128 l h)= put h >> put l

instance Decode Word128 where
    get = flip Word128 <$> get <*> get

instance Encode Word256 where
    put (Word256 lx hx l h) = do
        put h
        put l
        put hx
        put lx

instance Decode Word256 where
    get = do
        h <- get
        l <- get
        hx <- get
        lx <- get
        return (Word256 lx hx l h)

-- | 32 byte of data.
newtype H256 = H256 (Block Word8)
    deriving (Eq, Ord, ByteArrayAccess)

-- | Convert any 32 byte array into H256 type, otherwise returns Nothing.
h256 :: ByteArrayAccess a => a -> Maybe H256
h256 ba
  | A.length ba == 32 = Just $ H256 (convert ba)
  | otherwise = Nothing

instance FromHex H256 where
    fromHex bs
      | A.length bs == 32 = Right $ H256 (convert bs)
      | otherwise = Left ("wrong length: " ++ show (A.length bs))

instance ToHex H256 where
    toHex = fromBytes

instance Show H256 where
    show = show . toHex

instance IsString H256 where
    fromString = either error id . fromHex . fromString

instance Encode H256 where
    put = putByteString . convert

instance Decode H256 where
    get = (fromJust . h256) <$> getByteString 32

-- | 64 byte of data.
newtype H512 = H512 (Block Word8)
    deriving (Eq, Ord, ByteArrayAccess)

-- | Convert any 64 byte array into H512 type, otherwise returns Nothing.
h512 :: ByteArrayAccess a => a -> Maybe H512
h512 ba
  | A.length ba == 64 = Just $ H512 (convert ba)
  | otherwise = Nothing

instance FromHex H512 where
    fromHex bs
      | A.length bs == 64 = Right $ H512 (convert bs)
      | otherwise = Left ("wrong length: " ++ show (A.length bs))

instance ToHex H512 where
    toHex = fromBytes

instance Show H512 where
    show = show . toHex

instance IsString H512 where
    fromString = either error id . fromHex . fromString

instance Encode H512 where
    put = putByteString . convert

instance Decode H512 where
    get = (fromJust . h512) <$> getByteString 64
