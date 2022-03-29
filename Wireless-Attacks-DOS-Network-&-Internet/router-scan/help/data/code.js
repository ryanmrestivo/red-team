function ShowCode(Code)
{
	var tPAS = document.getElementById('CodeSnippetContainerTab_PAS');
	var cPAS = document.getElementById('CodeSnippetContainerCode_PAS');
	var tPS = document.getElementById('CodeSnippetContainerTab_PS');
	var cPS = document.getElementById('CodeSnippetContainerCode_PS');
	var tCPP = document.getElementById('CodeSnippetContainerTab_CPP');
	var cCPP = document.getElementById('CodeSnippetContainerCode_CPP');
	switch (Code)
	{
		case 'PAS':
		if (cPAS == null) return;
		tPAS.className = "codeSnippetContainerTabActive";
		cPAS.style.display = "block";
		if (cPS != null)
		{
			tPS.className = "codeSnippetContainerTab";
			cPS.style.display = "none";
		}
		if (cCPP != null)
		{
			tCPP.className = "codeSnippetContainerTab";
			cCPP.style.display = "none";
		}
		break;
		case 'PS':
		if (cPS == null) return;
		if (cPAS != null)
		{
			tPAS.className = "codeSnippetContainerTab";
			cPAS.style.display = "none";
		}
		tPS.className = "codeSnippetContainerTabActive";
		cPS.style.display = "block";
		if (cCPP != null)
		{
			tCPP.className = "codeSnippetContainerTab";
			cCPP.style.display = "none";
		}
		break;
		case 'CPP':
		if (cCPP == null) return;
		if (cPAS != null)
		{
			tPAS.className = "codeSnippetContainerTab";
			cPAS.style.display = "none";
		}
		if (cPS != null)
		{
			tPS.className = "codeSnippetContainerTab";
			cPS.style.display = "none";
		}
		tCPP.className = "codeSnippetContainerTabActive";
		cCPP.style.display = "block";
		break;
	}
}
