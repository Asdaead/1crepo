
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Для Каждого Движение Из Движения.Управленческий Цикл
		Движение.Период = Дата;
	КонецЦикла;
	
	Если НЕ ЭтоНовый() Тогда
		НабЗап = РегистрыБухгалтерии.Управленческий.СоздатьНаборЗаписей();
		НабЗап.Отбор.Регистратор.Установить(Ссылка);
		НабЗап.Прочитать();
		НабЗап.УстановитьАктивность(НЕ ПометкаУдаления);
		НабЗап.Записать();
	КонецЕсли;
		
КонецПроцедуры
