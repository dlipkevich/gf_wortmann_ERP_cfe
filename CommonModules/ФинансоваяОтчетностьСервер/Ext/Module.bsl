﻿
&После("СкопироватьОтборРекурсивно")
Процедура гф_СкопироватьОтборРекурсивно(ОтборИсточник, ОтборПриемник, ТолькоИспользуемые, ПоляИсключения, Постфикс, ПараметрыПроверкиДоступностиПолей)
	// #wortmann { 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee9062a7e31a79
	// Типовая дописывает всем отборам Постфикс, для нового отбора по Сумме этого не нужно делать
	// Галфинд_Домнышева 2023/12/08
	Для Каждого Элемент Из ОтборПриемник.Элементы Цикл
		Если ТипЗнч(Элемент) = Тип("ЭлементОтбораКомпоновкиДанных") 
			И Элемент.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Сумма" + Постфикс + ".") Тогда
			Элемент.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Сумма");
		КонецЕсли;		 
	КонецЦикла;
	// } #wortmann	
КонецПроцедуры
