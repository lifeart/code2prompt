import { Component, tracked } from '@lifeart/gxt';
import { Input } from '@/components/Input';
import { autofocus } from '@/modifiers/autofocus';
import { retrieveGithubRepoInfo } from './utils/repo-loader';
import { read, write } from './utils/persistent';
import { dirsToSkip, filesToSkip, knownExtensions } from './utils/constants';

export default class App extends Component {
  @tracked token = read<string>('token', '');
  updateToken = (e: Event) => {
    this.token = (e.target as HTMLInputElement).value;
    write('token', this.token);
  };
  @tracked
  name = read<string>('name', '');
  @tracked result = '';
  @tracked isLoading = false;
  @tracked knownExtensions = knownExtensions;
  @tracked filesToSkip = filesToSkip;
  @tracked dirsToSkip = dirsToSkip;
  get dirsToSkipAsString() {
    return this.dirsToSkip.join(', ');
  }
  get filesToSkipAsString() {
    return this.filesToSkip.join(', ');
  }
  get knownExtensionsAsString() {
    return this.knownExtensions.join(', ');
  }
  updateName = (e: Event) => {
    const node = e.target as HTMLInputElement;
    if (this.name === node.value) return;
    if (this.isLoading) {
      node.value = this.name;
      return;
    }
    this.name = node.value;
    write('name', this.name);
  };
  loadData = () => {
   this.result = '';
    this.isLoading = true;
    try {
      retrieveGithubRepoInfo(this.name, this.token, {
        dirsToSkip: this.dirsToSkip,
        filesToSkip: this.filesToSkip,
        knownExtensions: this.knownExtensions,
      })
        .then((result) => {
          this.result = result;
          this.isLoading = false;
        })
        .catch((e) => {
          this.result = String(e);
          this.isLoading = false;
        });
    } catch (e) {
      this.result = String(e);
      this.isLoading = false;
    }
  };
  updateList = (
    key: 'knownExtensions' | 'dirsToSkip' | 'filesToSkip',
    e: Event,
  ) => {
    const node = e.target as HTMLInputElement;
    const values = node.value.split(',').map((item) => item.trim());

    write(key, values);
    this[key] = values;
  };
  <template>
    <section style.min-width='600px'>
      <h2 class='text-orange-300' style.margin-bottom='20px'>
        Hello, User!
      </h2>
      <p>
        <div class='flex justify-between items-center'>
        <Input
          class='m-2'
          placeholder='Github token'
          @value={{this.token}}
          @onInput={{this.updateToken}}
        />
        </div>
        <div class='flex justify-between items-center'>
          <Input
            class='m-2 flex-grow'
            placeholder='Github repo link, like: https://github.com/lifeart/glimmerx-workshop/tree/master '
            @value={{this.name}}
            @onChange={{this.updateName}}
            disabled={{this.isLoading}}
            {{autofocus}}
          />
          <button class='m-2 p-2 bg-blue-500 text-white rounded-lg shadow-lg hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-300'
            disabled={{this.isLoading}}
            type='button'
            {{on "click" this.loadData}}>
            Submit
          </button>
        </div>
        <div class='flex justify-between items-center'>
        <details class='m-2 w-full'>
          <summary class='cursor-pointer text-blue-500'>Extra Configuration</summary>
          <div class='p-2 border rounded'>
            <label id="dirs-to-skip" class='text-white'>Exclude folders (comma-separated)</label>
            <Input
              class='m-2'
              id='dirs-to-skip'
              @value={{this.dirsToSkipAsString}}
              placeholder='Exclude folders (comma-separated)'
              @onChange={{fn this.updateList 'dirsToSkip'}}
            />
            <label id="files-to-skip" class='text-white'>Exclude files (comma-separated)</label>
            <Input
              class='m-2'
              id='files-to-skip'
              @value={{this.filesToSkipAsString}}
              placeholder='Exclude files (comma-separated)'
              title='Exclude folders (comma-separated)'
              @onChange={{fn this.updateList 'filesToSkip'}}
            />
            <label id="known-extensions" class='text-white'>Include extensions (comma-separated)</label>
            <Input
              class='m-2'
              id='known-extensions'
              @value={{this.knownExtensionsAsString}}
              placeholder='Include extensions (comma-separated)'
              title='Exclude folders (comma-separated)'
              @onChange={{fn this.updateList 'knownExtensions'}}
            />
          </div>
        </details>
        </div>
        {{#if this.isLoading}}
          <span class='m-2 text-white'>Loading...</span>
        {{/if}}
        <div class='flex justify-between items-center'>
        <textarea
          class='m-2 block p-2 w-full text-white text-left whitespace-pre overflow-x-scroll'
        >{{this.result}}</textarea>
        </div>
      </p>
    </section>
  </template>
}
