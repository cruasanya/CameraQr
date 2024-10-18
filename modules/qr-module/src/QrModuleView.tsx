import { ViewProps } from 'react-native';
import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

export type OnCodeScanned = {
  data: string;
};

export type Props = {
  onCodeScanned?: (event: { nativeEvent: OnCodeScanned}) => void;
} & ViewProps;

const NativeView: React.ComponentType<Props> = requireNativeViewManager('QrModuleView');

export default function QrModuleView(props: Props) {
  return <NativeView {...props} />;
}