import { Component, tracked } from '@lifeart/gxt';
import { Input } from '@/components/Input';
import { autofocus } from '@/modifiers/autofocus';

export default class App extends Component {
  @tracked
  name = 'world';
  updateName = (e: Event) => {
    this.name = (e.target as HTMLInputElement).value;
  };
  <template>
    <section>
      <h2 class='text-orange-300' style.margin-bottom='20px'>
        Hello, {{this.name}}!</h2>
      <p>
        <Input 
          @value={{this.name}}
          @onInput={{this.updateName}}
          {{autofocus}} />
      </p>
    </section>
  </template>
}
