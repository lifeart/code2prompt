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
  @tracked isLoading = false;
  updateName = (e: Event) => {
    const node = e.target as HTMLInputElement;
    if (this.name === node.value) return;
    if (this.isLoading) {
      node.value = this.name;
      return;
    }
    this.name = node.value;
    write('name', this.name);
    this.result = '';
    this.isLoading = true;
    try {
      retrieveGithubRepoInfo(
        this.name,
        this.token,
      ).then((result) => {
        this.result = result;
        this.isLoading = false;
      }).catch((e) => {
        this.result = String(e);
        this.isLoading = false;
      });
    } catch (e) {
      this.result = String(e);
      this.isLoading = false;
    }

  };
  <template>
    <section style.min-width="600px" >
      <h2 class='text-orange-300' style.margin-bottom='20px'>
        Hello, User!
      </h2>
      <p>
        <Input
          class='m-2'
          placeholder='Github token'
          @value={{this.token}}
          @onInput={{this.updateToken}}
        />
        <Input
          class='m-2'
          placeholder='Github repo link, like: https://github.com/lifeart/glimmerx-workshop/tree/master '
          @value={{this.name}}
          @onChange={{this.updateName}}
          disabled={{this.isLoading}}
          {{autofocus}}
        />
        {{#if this.isLoading}}
          <span class='m-2 text-white'>Loading...</span>
        {{/if}}
        <textarea class='m-2 block p-2 w-full text-white text-left whitespace-pre overflow-x-scroll'>{{this.result}}</textarea>
      </p>
    </section>
  </template>
}
