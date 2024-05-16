import { module, test } from 'qunit';
import { render } from '@lifeart/gxt/test-utils';
import { autofocus } from '@/modifiers/autofocus';

module('Integration | modifiers | autofocus', function () {
  test('works as expected', async function (assert) {
    await render(<template><input {{autofocus}} /></template>);
    assert.dom('input').isFocused();
  });
});
