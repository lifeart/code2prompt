import { Component, tracked } from '@lifeart/gxt';
import { Input } from '@/components/Input';
import { autofocus } from '@/modifiers/autofocus';
import { retrieveGithubRepoInfo } from './utils/repo-loader';
import { read, write } from './utils/persistent';

export default class App extends Component {
  @tracked token = read('token', '');
  updateToken = (e: Event) => {
    this.token = (e.target as HTMLInputElement).value;
    write('token', this.token);
  };
  @tracked
  name = read('name', '');
  @tracked result = '';
  updateName = (e: Event) => {
    this.name = (e.target as HTMLInputElement).value;
    write('name', this.name);
    this.result = '';
    retrieveGithubRepoInfo(
      this.name,
      this.token,
    ).then((result) => {
      this.result = result;
    });
  };
  <template>
    <section>
      <h2 class='text-orange-300' style.margin-bottom='20px'>
        Hello,
        {{this.name}}!</h2>
      <p>
        <Input
          class='m-2'
          @value={{this.token}}
          @onInput={{this.updateToken}}
        />
        <Input
          class='m-2'
          @value={{this.name}}
          @onInput={{this.updateName}}
          {{autofocus}}
        />
        <textarea class='m-2 block text-left whitespace-pre overflow-x-scroll'>{{this.result}}</textarea>
      </p>
    </section>
  </template>
}
