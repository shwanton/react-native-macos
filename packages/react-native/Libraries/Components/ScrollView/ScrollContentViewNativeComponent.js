/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @format
 * @flow
 */

import type {HostComponent} from '../../Renderer/shims/ReactNativeTypes';
import type {ViewProps} from '../View/ViewPropTypes';

import codegenNativeComponent from '../../Utilities/codegenNativeComponent';

type NativeProps = $ReadOnly<{|
  ...ViewProps,
  inverted?: ?boolean,
|}>;

export default (codegenNativeComponent<NativeProps>('ScrollContentView', {
  paperComponentName: 'RCTScrollContentView',
  excludedPlatforms: ['android'],
}): HostComponent<NativeProps>);
